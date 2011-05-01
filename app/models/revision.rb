# A revision history for Comments
class Revision
  include MongoMapper::Document
  
  key :original_id, ObjectId
  key :author_id, ObjectId
  key :revising_user_id, ObjectId
  key :body, String
  
  timestamps!
end
