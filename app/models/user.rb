class User
  include MongoMapper::Document
  plugin Joint
  
  key :zooniverse_user_id, Integer, :required => true
  key :name, String, :required => true
  key :publishable_name, String # do we need this in here.  If so, how do we keep these up to date
  timestamps!
  
  attachment :avatar
  
  many :collections
  many :messages, :class_name => "Discussion", :foreign_key => "focus_id"
end
