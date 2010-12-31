class ArchivedCollection
  include MongoMapper::Document
  
  key :zooniverse_id, String
  key :user_id, ObjectId
  
  key :collection_archive, Hash
  key :conversation_archive, Hash
  key :discussions_archive, Array
  
  timestamps!
end
