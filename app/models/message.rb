# A private Message between User
class Message
  include MongoMapper::Document
  
  key :title, String
  key :body, String
  timestamps!
  
  key :sender_id, ObjectId
  key :recipient_id, ObjectId
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  def sent_messages(no=100)
    
  end
end
