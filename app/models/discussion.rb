# A collection of Comment about a Focus
class Discussion
  include MongoMapper::Document
  
  key :subject, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, i.e. not the focus and also not a collection
  key :focus_id, ObjectId
  key :focus_type, String
  timestamps!
  
  many :comments
  
  # Fetches the Focus of this Discussion if it exists
  def focus
    return nil if focus_id.nil? || focus_type.nil?
    @cached_focus ||= focus_type.constantize.find(focus_id)
  end
  
  # A way to aggregate tags up to a discussion.  Take this with a grain of salt.
  def tags
    tags = Comment.collection.find({:discussion_id => id}, {:fields => [:tags]}).to_a
    tags = tags.collect{ |doc| doc['tags'] }.flatten
    
    counted_tags = Hash.new(0)
    tags.each{ |tag| counted_tags[tag] += 1 }
    self.tags = counted_tags.sort{ |a, b| b[1] <=> a[1] }.collect{ |tag| tag.first }
    self.save if changed?
    self.tags
  end
end
