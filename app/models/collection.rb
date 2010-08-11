class Collection
  include MongoMapper::EmbeddedDocument
  
  key :name, String, :required => true
  key :description, String
  key :tags, Array
  key :created_at, DateTime
  key :updated_at, DateTime
  
  key :asset_ids, Array
  many :assets, :in => :asset_ids
  belongs_to :user
  
  one :conversation, :class_name => "Discussion", :foreign_key => "focus_id"
  many :discussions, :foreign_key => "focus_id"
end
