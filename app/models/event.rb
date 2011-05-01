# The Event system for Comments and Users
class Event
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :details, String
  key :moderator_id, ObjectId
  key :state, String
  key :user_id, ObjectId, :required => true
  key :target_user_id, ObjectId, :required => true
  timestamps!
  
  belongs_to :user
  belongs_to :target_user, :class_name => "User"
  belongs_to :moderator, :class_name => "User"
  belongs_to :eventable, :polymorphic => true
  
  scope :pending_for_comments, :eventable_type => 'Comment', :state => 'pending'
  scope :pending_for_users, :eventable_type => 'User', :state => 'pending'
  scope :actioned, :state => 'actioned'
  scope :ignored, :state => 'ignored'
  
  state_machine :initial => :pending do
    event :action do
      transition :pending => :actioned
    end
    
    event :ignore do
      transition :pending => :ignored
    end
  end
  
  # The object this Event is targeting
  def target
    self.eventable
  end
  
  # Events pending for a user
  # @param user [User] the User the Events target
  def self.pending_for_user(user)
    Event.where(:state => "pending", :target_user_id => user.id)
  end
end
