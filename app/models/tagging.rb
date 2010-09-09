class Tagging
  include MongoMapper::Document
  
  key :name, String
  key :focus_id, ObjectId
  key :focus_type, String
  key :discussion_ids, Array
  key :comment_ids, Array
  key :count, Integer, :default => 0
end
