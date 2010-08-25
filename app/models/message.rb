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
  
  after_create :deliver_notification
  
  def deliver_notification
    Notifier.message_received(self).deliver
  end
  
  def mark_as_read
    Message.collection.update({ :_id => id }, { '$set' => { :unread => false } })
  end
  
  def recipient_name
    recipient.name
  end
  
  def recipient_name=(name)
    recipient = User.find_by_name(name)
  end
  
  def sent_to?(user)
    recipient_id == user.id
  end
  
  def sent_by?(user)
    sender_id == user.id
  end
  
  def visible_to?(user)
    sent_to?(user) || sent_by?(user)
  end
  
  def destroy_for(user)
    destroyed_by_sender = true if sent_by? user
    destroyed_by_recipient = true if sent_to? user
    destroy if destroyed_by_recipient and destroyed_by_sender
  end
  
  private
  def not_blocked
    if recipient.nil?
      errors.add(:base, I18n.t('models.messages.no_recipient'))
    elsif recipient.blocked_list.include? self.sender.id
      errors.add(:base, I18n.t('models.messages.blocked'))
    end
  end
end
