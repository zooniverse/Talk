# Users can have their own set of Discussion (private messages)
class User
  include MongoMapper::Document
  
  key :zooniverse_user_id, Integer, :required => true
  key :name, String, :required => true
  key :blocked_list, Array
  timestamps!
  
  many :collections
  many :live_collections
  many :comments, :foreign_key => :author_id
  many :messages, :foreign_key => :recipient_id
  many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
  
  def messages_with(user)
    sent_by_them = Message.all(:sender_id => user.id, :recipient_id => id)
    sent_by_me = Message.all(:sender_id => id, :recipient_id => user.id)
    combined = sent_by_me + sent_by_them
    combined.sort{ |a, b| b.created_at <=> a.created_at }
  end
end
