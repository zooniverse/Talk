# A collection of Comment about a Focus
class Discussion
  include MongoMapper::Document
  include ZooniverseId
  include Taggable
  
  
  zoo_id :prefix => "D"
  key :subject, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, i.e. not the focus and also not a collection
  key :focus_id, ObjectId
  key :focus_type, String
  key :slug, String
  key :number_of_users, Integer, :default => 0
  key :number_of_comments, Integer, :default => 0
  
  timestamps!
  
  many :comments
  
  before_create :set_slug
  before_save :update_tags
  before_save :update_counts
  
  # Creates a prettyfied slug for the URL
  def set_slug
    self.slug = self.subject.parameterize('_')
  end
  
  # Fetches the Focus of this Discussion if it exists
  def focus
    return nil if focus_id.nil? || focus_type.nil?
    @cached_focus ||= focus_type.constantize.find(focus_id)
  end
  
  def self.most_recent (no=10)
    Discussion.limit(no).sort(['created_at', -1]).all(:created_at.gt => Time.now - 1.day)
  end
  
  def most_recent_comments(no=10)
    Comment.where(:discussion_id => self.id).limit(no).all
  end
  
  # Finds discussions mentioning an asset
  def self.mentioning(asset)
    comments = Comment.mentioning(asset, :limit => 0)
    counted_comments = Hash.new(0)
    comments.each{ |comment| counted_comments[comment] += 1 }
    comments = counted_comments.sort{ |a, b| b[1] <=> a[1] }.collect{ |comment| comment.first }
    comments.collect{ |comment| comment.discussion }
  end
  
  def live_collection?
    return (focus_type == "LiveCollection")
  end
  
  def asset?
    return (focus_type == "Asset")
  end
  
  def collection?
    return (focus_type == "Collection")
  end
  
  private
  # A way to aggregate tags up to a discussion.  Take this with a grain of salt.
  def update_tags
    tags = Comment.collection.find({:discussion_id => id}, {:fields => [:tags]}).to_a
    tags = tags.collect{ |doc| doc['tags'] }.flatten
    
    counted_tags = Hash.new(0)
    tags.each{ |tag| counted_tags[tag] += 1 }
    self.tags = counted_tags.sort{ |a, b| b[1] <=> a[1] }.collect{ |tag| tag.first }
  end
  
  # KLUDGE: Must explicitly save discussions after adding comments
  def update_counts
    fresh_comments = Comment.collection.find(:discussion_id => id).to_a
    self.number_of_comments = fresh_comments.length
    self.number_of_users = fresh_comments.collect{ |c| c["author_id"] }.uniq.length
  end
end
