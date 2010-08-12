# A Comment on a Discussion by a User
class Comment
  include MongoMapper::Document
  
  key :discussion_id, ObjectId, :required => true
  key :author, ObjectId, :required => true
  key :response_to, ObjectId
  key :upvotes, Integer
  key :user_upvotes, Hash
  key :body, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, whether these make their way up to the discussion level is TBD
  timestamps!
  
  belongs_to :discussion
end
