# A collection of Comment about a Focus
class Discussion
  include MongoMapper::Document
  include ZooniverseId
  attr_accessible :subject
  
  zoo_id :prefix => "D"
  key :subject, String, :required => true
  key :focus_id, ObjectId
  key :focus_type, String
  key :focus_base_type, String
  key :slug, String
  key :started_by_id, ObjectId
  key :featured, Boolean, :default => false
  
  key :popularity, Integer
  key :number_of_users, Integer, :default => 0
  key :number_of_comments, Integer, :default => 0
  
  timestamps!
  
  many :comments, :dependent => :destroy
  
  before_create :set_slug
  before_create :set_started_by
  before_destroy :remove_from_board
  after_save :update_counts
  
  scope :featured, :featured => true
  
  # Fetches the Focus of this Discussion if it exists
  def focus
    return nil if focus_id.nil? || focus_type.nil?
    @cached_focus ||= focus_type.constantize.find(focus_id)
  end
  
  # Finds the most recent discussions
  def self.most_recent(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    Discussion.sort(:created_at.desc).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Finds popular discussions
  def self.trending(limit = 10)
    Discussion.limit(limit).sort(:popularity.desc).all
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
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    last_login = args.first ? args.first.last_login_at : nil
    last_login ||= Time.now.utc.beginning_of_day
    
    Discussion.sort(:updated_at.desc).where(:updated_at.gte => last_login).paginate(opts)
  end
  
  def count_new_comments(user = nil)
    last_login = user.nil? ? nil : user.last_login_at
    last_login ||= Time.now.utc.beginning_of_day
    
    self.comments.count(:created_at.gt => last_login)
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
  
  def board?
    focus_type == "Board"
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
    hash['comments'] = comments.collect(&:to_mongo)
    hash
  end
  
  private
  # Creates a prettyfied slug for the URL
  def set_slug
    self.slug = self.subject.parameterize('_')
  end
  
  # Sets the user that started this discussion
  def set_started_by
    return if self.comments.empty? || !self.started_by_id.nil?
    self.started_by_id = self.comments.first.author.id
  end
  
  # Updates the denormalized counts
  def update_counts
    fresh_comments = Comment.collection.find(:discussion_id => id).to_a
    n_comments = fresh_comments.length
    n_users = fresh_comments.collect{ |c| c["author_id"] }.uniq.length
    
    Discussion.collection.update({:_id => id}, {
      '$set' => {
        :number_of_comments => n_comments,
        :number_of_users => n_users,
        :popularity => n_users * n_comments
      }
    })
  end
  
  def remove_from_board
    self.focus.pull_discussion(self) if self.board?
  end
end
