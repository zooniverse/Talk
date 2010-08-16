# Users can have their own set of Discussion (private messages)
class User
  include MongoMapper::Document
  
  key :zooniverse_user_id, Integer, :required => true
  key :name, String, :required => true
  timestamps!
  
  many :collections
  many :comments
  many :messages, :class_name => "Discussion", :foreign_key => "focus_id"
end
