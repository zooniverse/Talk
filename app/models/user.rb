# Users can have their own set of Discussion (private messages)
class User
  include MongoMapper::Document
  
  key :zooniverse_user_id, Integer, :required => true
  key :name, String, :required => true
  key :email, String
  key :blocked_list, Array
  key :moderator, Boolean, :default => false
  key :admin, Boolean, :default => false
  key :state, String
  
  scope :watch_list, :state => 'watched'
  scope :banned_list, :state => 'banned'
  scope :moderators, :moderator => true
  
  state_machine :initial => :active do
    after_transition :on => :ban, :do => :notify_banned_user
    after_transition :on => :redeem, :do => :notify_redeemed_user
    
    event :ban do
      transition [:active, :watched] => :banned
    end
    
    event :watch do
      transition :active => :watched
    end
    
    event :redeem do
      transition [:banned, :watched] => :active
    end
  end
  
  timestamps!
  
  many :collections
  many :live_collections
  many :comments, :foreign_key => :author_id
  many :messages, :foreign_key => :recipient_id
  many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
  many :events, :as => :eventable
  
  def privileged?
    self.admin? || self.moderator?
  end
  
  def notify_banned_user
    Notifier.notify_banned_user(self).deliver
  end
  
  def notify_redeemed_user
    Notifier.notify_redeemed_user(self).deliver
  end
  
  def messages_with(user)
    sent_by_them = Message.all(:sender_id => user.id, :recipient_id => id)
    sent_by_me = Message.all(:sender_id => id, :recipient_id => user.id)
    combined = sent_by_me + sent_by_them
    combined.sort{ |a, b| b.created_at <=> a.created_at }
  end
end
