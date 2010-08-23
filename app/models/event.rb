class Event
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :details, String
  key :state, String, :default => "Pending"
  key :user_id, ObjectId
  timestamps!
    
  belongs_to :user
  belongs_to :eventable, :polymorphic => true

  scope :pending_for_comments, :eventable_type => 'Comment', :state => 'Pending'
  scope :pending_for_users, :eventable_type => 'User', :state => 'Pending'
end