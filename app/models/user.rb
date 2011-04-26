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
  
  many :collections
  many :keyword_sets
  many :comments, :foreign_key => :author_id
  many :messages, :foreign_key => :recipient_id
  many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
  many :events, :as => :eventable
  
  def online?
    return false if self.last_active_at.nil?
    self.last_active_at > 1.hour.ago.utc
  end
  
  # True if user is an admin or moderator
  def privileged?
    self.admin? || self.moderator?
  end
  
  def is_scientist?
    self.scientist
  end
  
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
  
  def can_modify?(document)
    case document
    when Comment
      self == document.author || self.privileged?
    when Discussion
      self == document.started_by || self.privileged?
    when Collection, KeywordSet
      self == document.user || self.privileged?
    else
      false
    end
  end
  
  def can_destroy?(document)
    case document
    when Comment
      self == document.author || self.privileged?
    when Discussion
      self.privileged? || (self == document.started_by && document.number_of_comments == 0)
    when Collection, KeywordSet
      self == document.user || self.privileged?
    else
      false
    end
  end
  
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
  
  def redeem(moderator)
    return false if self.state == "active"
    self.state = "active"
    Event.create(:user => moderator, :moderator => moderator, :target_user => self, :state => "actioned", :title => "#{ self.name } redeemed by #{ moderator.name }")
  end
  
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
  
  def unwatch(moderator)
    return false if self.state == "active"
    self.state = "active"
    Event.create(:user => moderator, :moderator => moderator, :target_user => self, :state => "actioned", :title => "#{ self.name } no longer watched by #{ moderator.name }")
  end
  
  # Emails a user when banned
  def notify_banned_user
    Notifier.notify_banned_user(self).deliver
  end
  
  # Emails a user when un-banned
  def notify_redeemed_user
    Notifier.notify_redeemed_user(self).deliver
  end
  
  # Finds messages between this user and another
  def messages_with(user)
    sent_by_them = Message.all(:sender_id => user.id, :recipient_id => id)
    sent_by_me = Message.all(:sender_id => id, :recipient_id => user.id)
    combined = sent_by_me + sent_by_them
    combined.sort{ |a, b| b.created_at <=> a.created_at }
  end
  
  def update_active!
    User.collection.update({ :_id => self._id }, {
      :$set => {
        :last_active_at => Time.now.utc
      }
    })
  end
  
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
