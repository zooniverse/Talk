# A Zooniverse User
class User
  include MongoMapper::Document
  
  key :zooniverse_user_id, Integer, :required => true
  key :name, String, :required => true
  key :last_active_at, Time
  key :current_login_at, Time
  key :last_login_at, Time
  key :email, String
  key :blocked_list, Array
  key :moderator, Boolean, :default => false
  key :admin, Boolean, :default => false
  key :scientist, Boolean, :default => false
  key :state, String
  
  scope :active, lambda { { :last_active_at.gt => 1.hour.ago.utc } }
  scope :watched, :state => 'watched'
  scope :banned, :state => 'banned'
  scope :moderators, :moderator => true
  scope :science_team, :scientist => true
  
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
  
  many :asset_sets
  many :comments, :foreign_key => :author_id
  many :messages, :foreign_key => :recipient_id
  many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
  many :events, :as => :eventable
  
  alias_method :collections, :asset_sets
  
  # True if the User has been active within the last hour
  def online?
    return false if self.last_active_at.nil?
    self.last_active_at > 1.hour.ago.utc
  end
  
  # True if User is an admin or moderator
  def privileged?
    self.admin? || self.moderator?
  end
  
  # True if the User is a scientist
  def is_scientist?
    self.scientist
  end
  
  # User name with role
  def formatted_name
    if self.scientist
      return "#{self.name} (science team)"
    elsif self.admin
      return "#{self.name} (admin)"
    elsif self.moderator
      return "#{self.name} (moderator)"
    else
      return "#{self.name}"
    end
  end
  
  # Rules for when a User can modify a document
  # @param document the document being modified
  def can_modify?(document)
    case document
    when Comment
      self == document.author || self.privileged?
    when Discussion
      self == document.started_by || self.privileged?
    when AssetSet, KeywordSet
      self == document.user || self.privileged?
    else
      false
    end
  end
  
  # Rules for when a User can destroy a document
  # @param document the document being destroyed
  def can_destroy?(document)
    case document
    when Comment
      self == document.author || self.privileged?
    when Discussion
      self.privileged? || (self == document.started_by && document.number_of_comments == 0)
    when AssetSet, KeywordSet
      self == document.user || self.privileged?
    else
      false
    end
  end
  
  # Ban this User
  # @param moderator [User] The User banning this User
  def ban(moderator)
    return false if self.state == "banned"
    self.state = "banned"
    pending = Event.pending_for_user(self).all
    
    if pending.any?
      pending.each do |event|
        event.state = "actioned"
        event.moderator = moderator
        event.save
      end
    else
      Event.create(:user => moderator, :moderator => moderator, :target_user => self, :state => "actioned", :title => "#{ self.name } banned by #{ moderator.name }")
    end
  end
  
  # Revoke a ban on this User
  # @param moderator [User] The User redeeming this User
  def redeem(moderator)
    return false if self.state == "active"
    self.state = "active"
    Event.create(:user => moderator, :moderator => moderator, :target_user => self, :state => "actioned", :title => "#{ self.name } redeemed by #{ moderator.name }")
  end
  
  # Initiate a watch on this User
  # @param moderator [User] The User adding a watch for this User
  def watch(moderator)
    return false if self.state == "watched"
    self.state = "watched"
    
    Event.pending_for_user(self).all.each do |event|
      event.state = "actioned"
      event.moderator = moderator
      event.save
    end
    
    Event.create(:user => moderator, :moderator => moderator, :target_user => self, :state => "actioned", :title => "#{ self.name } watched by #{ moderator.name }")
  end
  
  # Remove a watch on this User
  # @param moderator [User] The User removing the watch for this User
  def unwatch(moderator)
    return false if self.state == "active"
    self.state = "active"
    Event.create(:user => moderator, :moderator => moderator, :target_user => self, :state => "actioned", :title => "#{ self.name } no longer watched by #{ moderator.name }")
  end
  
  # Emails a User when banned
  def notify_banned_user
    Notifier.notify_banned_user(self).deliver
  end
  
  # Emails a User when redeemed
  def notify_redeemed_user
    Notifier.notify_redeemed_user(self).deliver
  end
  
  # Finds messages between this User and another User
  # @param user [User] The other User
  def messages_with(user)
    sent_by_them = Message.all(:sender_id => user.id, :recipient_id => id)
    sent_by_me = Message.all(:sender_id => id, :recipient_id => user.id)
    combined = sent_by_me + sent_by_them
    combined.sort{ |a, b| b.created_at <=> a.created_at }
  end
  
  # Marks this User as active (`last_active_at`)
  def update_active!
    User.collection.update({ :_id => self._id }, {
      :$set => {
        :last_active_at => Time.now.utc
      }
    })
  end
  
  # Updates the `last_login_at` and `current_login_at` for this User
  def update_login!
    last_login = self.current_login_at.nil? ? nil : self.current_login_at.utc
    
    User.collection.update({ :_id => self._id }, {
      :$set => {
        :last_login_at => last_login,
        :current_login_at => Time.now.utc
      }
    })
  end
end
