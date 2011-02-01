# A collection of Comment about a Focus
class Discussion
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  include ZooniverseId
  attr_accessible :subject
  
  zoo_id :prefix => "D"
  key :subject, String, :required => true
  key :focus_id, ObjectId
  key :focus_type, String
  key :focus_base_type, String
  key :started_by_id, ObjectId
  key :author_ids, Array
  key :featured, Boolean, :default => false
  
  key :popularity, Integer
  key :number_of_users, Integer, :default => 0
  key :number_of_comments, Integer, :default => 0
  
  timestamps!
  
  many :comments, :dependent => :destroy
  
  before_create :set_started_by
  before_destroy :remove_from_board
  after_save :update_counts
  
  # Fetches the Focus of this Discussion if it exists
  def focus
    return nil if focus_id.nil? || focus_type.nil?
    @cached_focus ||= focus_type.constantize.find(focus_id)
  end
  
  def self.featured
    sort(:updated_at.desc).where(:featured => true)
  end
  
  # Finds popular discussions
  def self.trending(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    Discussion.sort(:popularity.desc).where(:number_of_comments.gt => 0).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Finds discussions mentioning a focus
  def self.mentioning(focus, limit = 10)
    return [] if Comment.count == 0
    collected = Hash.new(0)
    page = 1
    
    begin
      comments = Comment.where(:mentions => focus.zooniverse_id).only(:discussion_id).paginate(:page => page)
      comments.each{ |comment| collected[comment.discussion_id] += 1 }
      comments = comments.next_page
    end while(comments && collected.length < limit)
    
    collected = collected.sort{ |a, b| b[1] <=> a[1] }.collect{ |id, count| id }.uniq
    collected[0, limit].map{ |id| find(id) }
  end
  
  # Finds the number of discussions mentioning a focus
  def self.count_mentions(focus)
    comments = Comment.where(:mentions => focus.zooniverse_id).only(:discussion_id).all
    comments.collect{ |c| c.discussion_id }.uniq.length
  end
  
  def self.with_new_comments(*args)
    opts = { :page => 1,
             :per_page => 10,
             :read_list => [],
             :for_user => nil,
             :by_user => false,
             :since => Time.now.utc.beginning_of_day
           }.update(args.extract_options!)
    
    since_time = opts[:for_user].last_login_at if opts[:for_user] && opts[:for_user].last_login_at
    since_time = Time.parse(opts[:since]) if opts[:since] && opts[:since].is_a?(String) && opts[:since].present?
    since_time = opts[:since].utc if opts[:since]
    
    cursor = Discussion.sort(:updated_at.desc).where(:updated_at.gte => since_time, :number_of_comments.gt => 0)
    cursor = cursor.where(:author_ids => opts[:for_user].id) if opts[:for_user] && opts[:by_user]
    cursor = cursor.where(:_id.nin => opts[:read_list]) if opts[:read_list].any?
    cursor.paginate(:page => opts[:page], :per_page => opts[:per_page])
  end
  
  class << self
    alias_method :recent, :with_new_comments
  end
  
  def count_new_comments(*args)
    opts = { :since => Time.now.utc.beginning_of_day, :for_user => nil }.update(args.extract_options!)
    since_time = opts[:for_user].last_login_at if opts[:for_user] && opts[:for_user].last_login_at
    since_time = opts[:since].utc if opts[:since]
    
    self.comments.count(:created_at.gte => since_time)
  end
  
  # True if discussing LiveCollections
  def live_collection?
    focus_type == "LiveCollection"
  end
  
  # True if discussing Assets
  def asset?
    focus_type == "Asset"
  end
  
  def board?
    focus_type == "Board"
  end
  
  # True if discussing Collections
  def collection?
    focus_type == "Collection"
  end
  
  # True if this is a focus conversation (live comment stream)
  def conversation?
    (focus_id.nil? || focus_type == "Board" ) ? false : focus.conversation == self
  end
  
  # Finds the user that started this discussion
  def started_by
    @cached_started_by ||= User.find(self.started_by_id)
  end
  
  # Sets the user that started this discussion
  def started_by=(user)
    @cached_started_by = user
    self.started_by_id = user.id
  end
  
  def keywords(limit = 10)
    Tag.for_discussion(self, limit).collect{ |t| t.name }
  end
  
  def to_embedded_hash
    hash = self.to_mongo
    hash['comments'] = comments.collect(&:to_embedded_hash)
    hash
  end
  
  def archive_and_destroy_as(destroying_user)
    Archive.create({
      :kind => "Discussion",
      :original_id => self.id,
      :zooniverse_id => self.zooniverse_id,
      :user_id => self.started_by_id,
      :destroying_user_id => destroying_user.id,
      :original_document => self.to_embedded_hash
    })
    
    self.destroy
  end
  
  # Sets the user that started this discussion
  def set_started_by
    return if self.comments.empty? || !self.started_by_id.nil?
    self.started_by_id = self.comments.first.author.id
  end
  
  # Updates the denormalized counts
  def update_counts
    fresh_comments = Comment.collection.find(:discussion_id => id).to_a
    
    authors = []
    recent_authors = []
    n_recent_comments = n_recent_upvotes = 0
    
    fresh_comments.each do |comment|
      if comment['created_at'].utc > 1.week.ago.utc
        recent_authors << comment['author_id']
        n_recent_comments += 1
        n_recent_upvotes += comment['upvotes'].length
      end
      
      authors << comment['author_id']
    end
    
    new_popularity = recent_authors.uniq.length + n_recent_comments + n_recent_upvotes
    authors.uniq!
    
    Discussion.collection.update({:_id => id}, {
      '$set' => {
        :number_of_comments => fresh_comments.length,
        :number_of_users => authors.length,
        :popularity => new_popularity,
        :author_ids => authors
      }
    })
    
    focus.update_popularity unless focus.nil? || focus.is_a?(Board)
  end
  
  def remove_from_board
    self.focus.pull_discussion(self) if self.board?
  end
  
  def path(*args)
    return discussion_path(self.zooniverse_id) unless focus.present?
    opts = args.extract_options!
    
    if self.conversation?
      self.focus.conversation_path self, opts
    else
      self.focus.discussion_path self, opts
    end
  end
  
  def parent_path(*args)
    return root_path unless focus.present?
    opts = args.extract_options!
    
    case self.focus.class.to_s
    when "Asset"
      object_path(focus.zooniverse_id, opts)
    when "Board"
      opts.delete(:page) if opts[:page] == 1
      query_string = opts.any? ? "?#{ opts.to_query }" : ""
      "/#{focus.title.downcase}#{ query_string }"
    when "Collection", "LiveCollection"
      collection_path(focus.zooniverse_id, opts)
    when "Group"
      group_path(focus.zooniverse_id, opts)
    end
  end
end
