class Event
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :details, String
  key :state, String, :default => "pending"
  key :user_id, ObjectId, :required => true
  timestamps!
    
  belongs_to :user
  belongs_to :eventable, :polymorphic => true

  scope :pending_for_comments, :eventable_type => 'Comment', :state => 'pending'
  scope :pending_for_users, :eventable_type => 'User', :state => 'pending'
  
  def target
    self.eventable
  end
end