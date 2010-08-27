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
  
  def self.most_recent (no=10)
    Discussion.limit(no).sort(['created_at', -1]).all
  end
  
  def most_recent_comments(no=10)
    Comment.where(:discussion_id => self.id).limit(no).all
  end
  
  def self.trending (no=10)
    Discussion.limit(no).sort(['number_of_comments',-1]).all
  end
  
  # Finds discussions mentioning a focus
  def self.mentioning(focus)
    return [] if Comment.count == 0
    comments = Comment.search "mentions:#{focus.zooniverse_id}", :limit => 100, :collapse => :discussion_id, :from_mongo => true
    comments[0, 10].map{ |comment| comment.discussion }
  end
  
  def live_collection?
    focus_type == "LiveCollection"
  end
  
  def asset?
    focus_type == "Asset"
  end
  
  def collection?
    focus_type == "Collection"
  end
  
  def conversation?
    focus_id.nil? ? false : focus.conversation == self
  end
  
  def started_by
    @cached_started_by ||= User.find(self.started_by_id)
  end
  
  def started_by=(user)
    @cached_started_by = user
    self.started_by_id = user.id
  end
  
  private
  # Creates a prettyfied slug for the URL
  def set_slug
    self.slug = self.subject.parameterize('_')
  end
  
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
