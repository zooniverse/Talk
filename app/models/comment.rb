class Comment
  include MongoMapper::Document
  plugin Joint
  
  key :discussion_id, ObjectId, :required => true
  key :author, Integer, :required => true
  key :response_to, ObjectId
  key :upvotes, Integer
  key :body, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, whether these make their way up to the discussion level is TBD
  timestamps!
  
  belongs_to :discussion
  attachment :file
end
