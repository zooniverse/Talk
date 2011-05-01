# A private Message between Users
class Message
  include MongoMapper::Document
  attr_accessible :title, :body
  
  key :title, String
  key :body, String
  key :unread, Boolean, :default => true
  timestamps!
  
  key :sender_id, ObjectId
  key :destroyed_by_sender, Boolean, :default => false
  
  key :recipient_id, ObjectId
  key :destroyed_by_recipient, Boolean, :default => false
  
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  validate :custom_validations
  
  after_create :deliver_notification
  
  # Sends an email to the recipient of a Message
  def deliver_notification
    Notifier.message_received(self).deliver
  end
  
  # Marks a message as read
  def mark_as_read
    Message.collection.update({ :_id => id }, { '$set' => { :unread => false } })
  end
  
  # The recipient name
  def recipient_name
    self.recipient.name
  end
  
  # Sets the recipient by User name
  def recipient_name=(name)
    user = User.find_by_name(name)
    self.recipient = user unless user.nil?
  end
  
  # True if User is the recipient
  def sent_to?(user)
    recipient_id == user.id
  end
  
  # True if User is the sender
  def sent_by?(user)
    sender_id == user.id
  end
  
  # True if User is the sender or recipient
  def visible_to?(user)
    sent_to?(user) || sent_by?(user)
  end
  
  # The Message is only destroyed when both recipient and sender have deleted it
  def destroy_for(user)
    self.destroyed_by_sender = true if sent_by? user
    self.destroyed_by_recipient = true if sent_to? user
    
    if destroyed_by_recipient and destroyed_by_sender
      destroy
    else
      save
    end
  end
  
  private
  # Validation ensuring that the sender is not blocked by the recipient
  def custom_validations
    if !self.recipient.nil? && self.recipient.blocked_list.include?(self.sender.id)
      self.errors.add(:base, I18n.t('models.messages.blocked'))
    end
    
    self.errors.add(:base, I18n.t('models.messages.no_recipient')) if self.recipient.nil?
    self.errors.add(:base, "Message can't be blank") if self.body.nil? || self.body.blank?
    self.errors.add(:base, "Message title can't be blank") if self.title.nil? || self.title.blank?
  end
end
