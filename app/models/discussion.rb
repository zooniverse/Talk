# A collection of Comment about a Focus
class Discussion
  include MongoMapper::Document
  include ZooniverseId
  include Taggable
  plugin Xapify
  
  zoo_id :prefix => "D"
  key :subject, String, :required => true
  key :focus_id, ObjectId
  key :focus_type, String
  key :slug, String
  key :started_by_id, ObjectId
  key :featured, Boolean, :default=>false 

  key :number_of_users, Integer, :default => 0
  key :number_of_comments, Integer, :default => 0
  
  timestamps!
  
  many :comments
  
  before_create :set_slug
  before_create :set_started_by
  after_save :update_counts
  
  scope :featured, :featured=>true 
  
  xapify_fields :tags
  
  # Fetches the Focus of this Discussion if it exists
  def focus
    return nil if focus_id.nil? || focus_type.nil?
    @cached_focus ||= focus_type.constantize.find(focus_id)
  end
  
  # Finds the most recent discussions
  def self.most_recent(limit = 10)
    Discussion.limit(limit).sort([:created_at, :desc]).all
  end
  
  # Finds the most recent comments in this discussion
  def most_recent_comments(limit = 10)
    Comment.limit(limit).all(:discussion_id => self.id)
  end
  
  # Finds popular discussions
  def self.trending(limit = 10)
    Discussion.limit(limit).sort([:number_of_comments, :desc]).all
  end
  
  # Finds discussions mentioning a focus
  def self.mentioning(focus, limit = 10)
    return [] if Comment.count == 0
    comments = Comment.search "mentions:#{focus.zooniverse_id}", :limit => 100, :collapse => :discussion_id, :from_mongo => true
    comments[0, limit].map{ |comment| comment.discussion }
  end
  
  # True if discussing LiveCollections
  def live_collection?
    focus_type == "LiveCollection"
  end
  
  # True if discussing Assets
  def asset?
    focus_type == "Asset"
  end
  
  # True if discussing Collections
  def collection?
    focus_type == "Collection"
  end
  
  # True if this is a focus conversation (live comment stream)
  def conversation?
    focus_id.nil? ? false : focus.conversation == self
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
  
  private
  # Creates a prettyfied slug for the URL
  def set_slug
    self.slug = self.subject.parameterize('_')
  end
  
  # Sets the user that started this discussion
  def set_started_by
    self.started_by_id = self.comments.first.author.id unless self.comments.empty?
  end
  
  # Updates the denormalized counts
  def update_counts
    fresh_comments = Comment.collection.find(:discussion_id => id).to_a
    n_comments = fresh_comments.length
    n_users = fresh_comments.collect{ |c| c["author_id"] }.uniq.length
    
    Discussion.collection.update({:_id => id}, {
      '$set' => { :number_of_comments => n_comments, :number_of_users => n_users }
    })
  end
end
