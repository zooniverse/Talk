# An Archive of a removed Document
class Archive
  include MongoMapper::Document
  
  key :kind, String
  key :original_id, ObjectId
  key :zooniverse_id, String
  key :user_id, ObjectId
  key :destroying_user_id, ObjectId
  key :original_document, Hash
  
  timestamps!
end
