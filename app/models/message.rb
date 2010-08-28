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
  
  # Sends an email to the recipient of a message
  def deliver_notification
    Notifier.message_received(self).deliver
  end
  
  # Marks a message as read
  def mark_as_read
    Message.collection.update({ :_id => id }, { '$set' => { :unread => false } })
  end
  
  # The recipients name
  def recipient_name
    self.recipient.name
  end
  
  # Sets the recipient by user-name
  def recipient_name=(name)
    user = User.find_by_name(name)
    self.recipient = user unless user.nil?
  end
  
  # True if user is the recipient
  def sent_to?(user)
    recipient_id == user.id
  end
  
  # True if user is the sender
  def sent_by?(user)
    sender_id == user.id
  end
  
  # True if user is the sender or recipient
  def visible_to?(user)
    sent_to?(user) || sent_by?(user)
  end
  
  # The message is only destroyed when both recipient and sender have deleted it
  def destroy_for(user)
    self.destroyed_by_sender = true if sent_by? user
    self.destroyed_by_recipient = true if sent_to? user
    destroy if destroyed_by_recipient and destroyed_by_sender
  end
  
  private
  # Validation ensuring that the sender is not blocked by the recipient
  def not_blocked
    if recipient.nil?
      errors.add(:base, I18n.t('models.messages.no_recipient'))
    elsif recipient.blocked_list.include? self.sender.id
      errors.add(:base, I18n.t('models.messages.blocked'))
    end
  end
end
