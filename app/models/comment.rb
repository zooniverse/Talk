class Comment
  include MongoMapper::Document
  plugin Joint
  
  key :discussion_id, ObjectId, :required => true
  key :author, Integer, :required => true
  key :response_to, ObjectId
  key :upvotes, Integer
  key :body, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets
  timestamps!
  
  belongs_to :discussion
  attachment :file
end
