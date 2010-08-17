# Users can have their own set of Discussion (private messages)
class User
  include MongoMapper::Document
  
  key :zooniverse_user_id, Integer, :required => true
  key :name, String, :required => true
  timestamps!
  
  many :collections
  many :live_collections
  many :comments
  many :messages, :foreign_key => :recipient_id
  many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
end
