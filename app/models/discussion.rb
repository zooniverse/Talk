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
  
  def focus
    return nil if focus_id.nil? || focus_type.nil?
    @cached_focus ||= focus_type.constantize.find(focus_id)
  end
end
