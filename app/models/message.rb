# A private Message between User
class Message
  include MongoMapper::Document
  
  key :title, String
  key :body, String
  key :unread, Boolean, :default => true
  timestamps!
  
  key :sender_id, ObjectId
  key :recipient_id, ObjectId
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  def mark_as_read
    Message.collection.update({ :_id => id }, { '$set' => { :unread => false } })
  end
end
