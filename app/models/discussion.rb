# A collection of Comment about a Focus
class Discussion
  include MongoMapper::Document
  include ZooniverseId
  include Taggable
  
  
  zoo_id :prefix => "D"
  key :subject, String, :required => true
  key :tags, Array
  key :mentions, Array # mentioned Focii, i.e. not the focus
  key :focus_id, ObjectId
  key :focus_type, String
  key :slug, String

  key :number_of_users, Integer, :default => 0
  key :number_of_comments, Integer, :default => 0
  
  timestamps!
  
  many :comments
  
  before_create :set_slug
  before_save :aggregate_comments
  after_save :update_counts
  
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
  
  # private
  # Creates a prettyfied slug for the URL
  def set_slug
    self.slug = self.subject.parameterize('_')
  end
  
  # Aggregate tags and mentions from comments
  def aggregate_comments
    self.tags = collect_comment_attribute 'tags'
    self.mentions = collect_comment_attribute 'mentions'
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
  
  # Aggregates and sorts an attribute on associated comments
  def collect_comment_attribute(attribute)
    raw = Comment.collection.find({:discussion_id => id}, {:fields => [attribute]}).to_a
    raw = raw.collect{ |doc| doc[attribute] }.flatten
    
    counted = Hash.new(0)
    raw.each{ |attrib| counted[attrib] += 1 }
    counted = counted.sort{ |a, b| b[1] <=> a[1] }.collect{ |attrib| attrib.first }
  end
end
