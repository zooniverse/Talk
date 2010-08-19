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
  
  validate :not_blocked
  
  def mark_as_read
    Message.collection.update({ :_id => id }, { '$set' => { :unread => false } })
  end
  
  private
  def not_blocked
    if recipient.blocked_list.include? self.sender.id
      errors.add(:base, I18n.t('messages.blocked'))
    end
  end
end
