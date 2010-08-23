class Event
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :details, String
  key :state, String
  key :user_id, ObjectId, :required => true
  timestamps!
    
  belongs_to :user
  belongs_to :eventable, :polymorphic => true

  scope :pending_for_comments, :eventable_type => 'Comment', :state => 'pending'
  scope :pending_for_users, :eventable_type => 'User', :state => 'pending'
  scope :actioned, :state => 'actioned'
  
  state_machine :initial => :pending do
    event :action do
      transition :pending => :actioned
    end
    
    event :ignore do
      transition :pending => :ignored
    end
  end 
  
  def target
    self.eventable
  end
end