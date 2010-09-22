# A Comment on a Discussion by a User
class Comment
  include MongoMapper::Document
  
  key :discussion_id, ObjectId
  key :response_to_id, ObjectId
  key :author_id, ObjectId, :required => true
  key :upvotes, Array
  key :body, String, :required => true
  key :_body, Array
  key :tags, Array
  key :mentions, Array # mentioned Focii, whether these make their way up to the discussion level is TBD
  key :focus_id, ObjectId
  key :focus_type, String
  timestamps!
  
  belongs_to :discussion
  belongs_to :author, :class_name => "User"
  many :events, :as => :eventable
  
  after_validation_on_create :parse_body
  before_create :split_body, :set_focus
  after_create :create_tags
  
  TAG = /#([-\w\d]{3,40})/im
  MENTION = /([A|C|D]MZ\w{7})/m
  
  def self.search(*args)
    opts = { :page => 1, :operator => :$all, :per_page => 10, :order => :created_at.desc, :field => :_body }.update(args.extract_options!)
    args = args.collect{ |arg| arg.split }.flatten
    opts[:per_page] = opts[:limit] if opts.has_key?(:limit)
    
    criteria = opts[:criteria] || {}
    criteria[:focus_type] = opts[:focus_type].singularize.camelize if opts.has_key?(:focus_type)
    criteria.merge!(opts[:field] => { opts[:operator] => args }) unless args.nil?
    return [] if criteria.blank?
    where(criteria).sort(opts[:order]).paginate(:page => opts[:page], :per_page => opts[:per_page])
  end
  
  # Sets the comment being responded to
  def response_to=(comment)
    self.response_to_id = comment.id
    self.save if self.changed?
    @cached_response_to = comment
  end
  
  # The comment being responded to
  def response_to
    @cached_response_to ||= Comment.find(self.response_to_id)
  end
  
  # True if this comment is a response
  def response?
    self.response_to_id.nil? ? false : true
  end
  
  # Atomic operation to let a User vote for a Comment
  def cast_vote_by(user)
    return if author.id == user.id
    Comment.collection.update({ '_id' => self.id }, {'$addToSet' => { 'upvotes' => user.id } })
  end
  
  # The most recent comments
  def self.most_recent(limit = 10)
    Comment.limit(limit).sort(:created_at.desc).all
  end
  
  # Finds comments mentioning a focus
  def self.mentioning(focus, *args)
    opts = { :page => 1, :per_page => 10, :order => :created_at.desc }.update(args.extract_options!)
    Comment.sort(opts[:order]).where(:mentions => focus.zooniverse_id).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Finds the number of comments mentioning a focus
  def self.count_mentions(focus)
    Comment.where(:mentions => focus.zooniverse_id).count
  end
  
  # The focus of this comment
  def focus
    return nil unless self.focus_type && self.focus_id
    self.focus_type.constantize.find(self.focus_id)
  end
  
  def split_body
    self._body = self.body.split
  end
  
  # Finds tags and mentions in the comment body
  def parse_body
    self.tags = self.body.scan(TAG).flatten
    self.mentions = self.body.scan(MENTION).flatten
  end
  
  # Sets the focus of this comment
  def set_focus
    self.focus_id = discussion.focus_id unless discussion.nil?
    self.focus_type = discussion.focus_type unless discussion.nil?
  end
  
  # Adds tags from this comment to the discussion and focus
  def create_tags
    if focus_type == "Asset" && self.tags.any?
      Asset.collection.update({ :_id => focus_id }, { :$addToSet => { :tags => { :$each => self.tags } } })
    end
    
    self.tags.uniq.each do |tag_name|
      Tag.collection.update({ :name => tag_name }, { :$inc => { :count => 1 } }, :upsert => true)
      
      unless focus_id.nil?
        Tagging.collection.update({ :name => tag_name, :focus_id => focus_id, :focus_type => focus_type }, {
          :$addToSet => { :discussion_ids => self.discussion_id, :comment_ids => self.id },
          :$inc => { :count => 1 }
        }, :upsert => true)
      end
    end
  end
end
