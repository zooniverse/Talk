# A Comment on a Discussion by a User
class Comment
  include MongoMapper::Document
  attr_accessible :response_to_id, :body
  
  key :discussion_id, ObjectId
  key :response_to_id, ObjectId
  key :author_id, ObjectId, :required => true
  key :upvotes, Array
  key :edit_count, Integer, :default => 0
  key :body, String, :required => true
  key :_body, Array
  key :tags, Array
  key :mentions, Array # mentioned Focii, whether these make their way up to the discussion level is TBD
  key :focus_id, ObjectId
  key :focus_type, String
  key :focus_base_type, String
  timestamps!
  
  belongs_to :discussion
  belongs_to :author, :class_name => "User"
  many :events, :as => :eventable
  
  after_validation :parse_body, :on => :create
  before_create :set_focus, :split_body
  after_create :create_tags
  after_validation :synchronize, :on => :update
  before_destroy :destroy_tags, :nullify_responses
  after_destroy :denormalize_counts
  
  # The Regexp used to parse Tags from Comments
  TAG = /[^\w]#([-\w\d]{3,40})/im
  
  # The Regexp used to parse mentions from Comments
  MENTION = /([A|C|D|S]MZ\w{7})/m
  
  # Until MongoMapper includes full-text search, this is how searching is implemented
  # @param *args [Array] The search terms
  # @option *args [Fixnum] :page (1) The page of results to find
  # @option *args [Fixnum] :per_page (10) The number of results per page
  # @option *args [Symbol] :operator (:$all) The MM operator logic to use
  # @option *args [Symbol] :order (:created_at.desc) The sort order to use
  # @option *args [Symbol] :field (:_body) The Document key to search on
  def self.search(*args)
    opts = { :page => 1, :operator => :$all, :per_page => 10, :order => :created_at.desc, :field => :_body }.update(args.extract_options!)
    args = args.collect(&:split).flatten
    args = args.map{ |arg| arg.downcase.gsub(/\W/, '') } if opts[:field] == :_body
    opts[:per_page] = opts[:limit] if opts.has_key?(:limit)
    
    criteria = opts[:criteria] || {}
    criteria[:focus_type] = opts[:focus_type].singularize.camelize if opts.has_key?(:focus_type)
    criteria.merge!(opts[:field] => { opts[:operator] => args }) unless args.nil?
    return [] if criteria.blank?
    where(criteria).sort(opts[:order]).paginate(:page => opts[:page], :per_page => opts[:per_page])
  end
  
  # Sets the Comment being responded to
  # @param Comment [Comment] The Comment being responded to
  def response_to=(comment)
    self.response_to_id = comment.id
    self.save if self.changed?
    @cached_response_to = comment
  end
  
  # The Comment being responded to
  def response_to
    @cached_response_to ||= Comment.find(self.response_to_id)
  end
  
  # True if this Comment is a response to another
  def response?
    self.response_to_id.nil? ? false : true
  end
  
  # Atomic operation to let a User vote for a Comment
  # @param user [User] The User upvoting this Comment
  def cast_vote_by(user)
    return if author.id == user.id
    Comment.collection.update({ '_id' => self.id }, {'$addToSet' => { 'upvotes' => user.id } })
    self.discussion.update_counts
  end
  
  # The most recent Comments
  # @param *args [Array] Pagination options
  # @option *args [Fixnum] :page (1) The page of Comments to find
  # @option *args [Fixnum] :per_page (10) The number of Comments per page
  def self.recent(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    Comment.sort(:created_at.desc).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Finds Comments mentioning a Focus
  # @param focus The Focus to search for
  # @option *args [Fixnum] :page (1) The page of results to find
  # @option *args [Fixnum] :per_page (10) The number of results per page
  # @option *args [Symbol] :order (:created_at.desc) The sort order to use
  def self.mentioning(focus, *args)
    opts = { :page => 1, :per_page => 10, :order => :created_at.desc }.update(args.extract_options!)
    Comment.sort(opts[:order]).where(:mentions => focus.zooniverse_id).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Counts the number of Comments that mention a Focus
  # @param focus The Focus to search for
  def self.count_mentions(focus)
    Comment.where(:mentions => focus.zooniverse_id).count
  end
  
  # The focus of this comment
  def focus
    return nil unless self.focus_type && self.focus_id
    self.focus_type.constantize.find(self.focus_id)
  end
  
  # Counts how many Comments came before this one.
  # @return [Fixnum] List position
  def position
    direction = self.discussion.conversation? ? :created_at.gt : :created_at.lt
    self.discussion.comments.sort(:created_at.desc).count(direction => self.created_at)
  end
  
  # Returns a targeted path to this Comment
  # @option *args [Fixnum] :per_page (10) The number of Comments per page
  def path(*args)
    opts = { :per_page => 10 }.update(args.extract_options!)
    position = self.position
    page = (position / opts[:per_page]) + 1
    
    if self.discussion.conversation?
      "#{ self.discussion.path(:per_page => [position + 1, 10].max) }##{ self._id }"
    else
      "#{ self.discussion.path(:per_page => opts[:per_page], :page => page) }##{ self._id }"
    end
  end
  
  # Synchronizes denormalized values
  def synchronize
    return if new_record? # Apparently in Rails 3.0.7 after_validation_on_update callbacks are triggered on new records
    split_body
    parse_body
    synchronize_tags
  end
  
  # Splits the body into an array and appends some metadata for searching
  def split_body
    self._body = self.body.gsub(/\W/, ' ').split
    
    if focus && focus_type != "Board"
      [:name, :description, :zooniverse_id].each do |attr|
        value = focus.send(attr) if focus.respond_to?(attr)
        self._body << value.gsub(/\W/, ' ').split unless value.nil?
      end
      
      self._body << discussion.subject.gsub(/\W/, ' ').split unless discussion.nil?
      self._body << discussion.zooniverse_id unless discussion.zooniverse_id.nil?
    end
    
    self._body = self._body.flatten.map(&:downcase).uniq
  end
  
  # Finds tags and mentions in the comment body
  def parse_body
    parsable = " #{ self.body }"
    self.tags = parsable.scan(TAG).flatten.map(&:downcase).uniq if self.body
    self.mentions = parsable.scan(MENTION).flatten.uniq if self.body
  end
  
  # Updates attributes with Revision history
  # @param *args [Array] The change Hash
  # @option *args [User] :revising_user (author) The User invoking the change.  Could also being a moderator or admin
  def update_attributes(*args)
    opts = { :revising_user => self.author }.update(args.extract_options!)
    
    self.attributes = args.first
    create_revision_as opts[:revising_user]
    self.save
  end
  
  # Create a revision by a User
  # @param revising_user [User] The User revising the Comment
  def create_revision_as(revising_user)
    return unless changes['body']
    
    Revision.create({
      :original_id => self.id,
      :author_id => self.author_id,
      :revising_user_id => revising_user.id,
      :body => changes['body'][0]
    })
    
    self.edit_count += 1
  end
  
  # Serialize to an embedded hash that also contains a serialized revision history
  def to_embedded_hash
    hash = self.to_mongo
    hash['revisions'] = Revision.all(:original_id => self.id).collect(&:to_mongo)
    hash
  end
  
  # Archive and destroy this Comment
  # @param destroying_user [User] The User destroying this Comment
  def archive_and_destroy_as(destroying_user)
    Archive.create({
      :kind => "Comment",
      :original_id => self.id,
      :user_id => self.author_id,
      :destroying_user_id => destroying_user.id,
      :original_document => self.to_embedded_hash
    })
    
    self.events.each do |event|
      event.moderator = destroying_user
      event.state = "actioned"
      event.save
    end
    
    self.destroy
  end
  
  # Sets the Focus of this Comment
  def set_focus
    self.focus_id = discussion.focus_id unless discussion.nil?
    self.focus_type = discussion.focus_type unless discussion.nil?
    self.focus_base_type = discussion.focus_base_type unless discussion.nil?
  end
  
  # Denormalize Tags from this Comment to the Discussion and Focus
  def create_tags
    push_tags self.tags
  end
  
  # Clean up responses referring to this Comment (on destroy)
  def nullify_responses
    Comment.collection.update({
      :response_to_id => self.id
    }, {
      :$set => {
        :response_to_id => nil
      }
    }, :multi => true)
  end
  
  # Removes tags created by this Comment (on destroy)
  def destroy_tags
    pull_tags self.tags
  end
  
  # Trigger the Discussion's denormalized counter
  def denormalize_counts
    self.discussion.update_counts if self.discussion
  end
  
  # Denormalize Tags from this Comment to the Discussion and Focus
  def synchronize_tags
    if changes["tags"]
      added = changes["tags"][1] - changes["tags"][0]
      removed = changes["tags"][0] - changes["tags"][1]
      
      push_tags added if added.any?
      pull_tags removed if removed.any?
    end
  end
  
  # Adds new Tags to the Discussion and Focus
  def push_tags(new_tags)
    if %w(Asset AssetSet Group).include?(focus_type) && new_tags.any?
      klass = focus_type.constantize
      klass.collection.update({ :_id => focus_id }, { :$addToSet => { :tags => { :$each => new_tags } } })
    end
    
    new_tags.each do |tag_name|
      Tag.collection.update({ :name => tag_name }, { :$inc => { :count => 1 } }, :upsert => true)
      
      unless focus_id.nil?
        Tagging.collection.update({ :name => tag_name, :focus_id => focus_id, :focus_type => focus_type }, {
          :$addToSet => { :discussion_ids => self.discussion_id, :comment_ids => self.id },
          :$inc => { :count => 1 }
        }, :upsert => true)
      end
    end
  end
  
  # Removes tags from the Discussion and Focus
  def pull_tags(old_tags)
    old_tags.each do |old_tag|
      selector = {
        :name => old_tag,
        :focus_id => self.focus_id
      }
      
      # at least remove the comment from the tagging and decrement the count
      updater = {
        :$pull => { :comment_ids => self.id },
        :$inc => { :count => -1 }
      }
      
      tagging = Tagging.first(selector)
      
      if tagging.count == 1
        # remove the tagging if the count would just go to 0
        Tagging.collection.remove(selector)
        
        if %w(Asset AssetSet Group).include?(focus_type)
          klass = focus_type.constantize
          
          # remove the tag from the focus if it's not in use anymore
          klass.collection.update({ :_id => focus_id }, {
            :$pull => { :tags => old_tag }
          })
        end
        
      else
        # if only one comment in this discussion has used the tag, then pull the discussion_id from the tagging
        ids = Comment.where(:discussion_id => self.discussion_id).only(:_id).all.collect(&:_id)
        pull_discussion = tagging.comment_ids.select{ |id| ids.include?(id) }.length > 1 ? false : true
        
        updater.merge!({
          :$pull => {
            :comment_ids => self.id,
            :discussion_ids => self.discussion_id
          }
        }) if pull_discussion
        
        Tagging.collection.update(selector, updater)
      end
      
      # Decrement the count for this tag
      Tag.collection.update({ :name => old_tag }, {
        :$inc => { :count => -1 }
      })
      
      # Destroy this tag only if the count has gone to 0
      Tag.collection.remove({ :name => old_tag, :count => 0 })
    end
  end
end
