class Tag
  include MongoMapper::Document
  
  key :tags, Array, :required => true
  key :asset_ids, Array  # for caching?
  
  many :assets, :in => :asset_ids
  
  one :conversation, :class_name => "Discussion", :foreign_key => "focus_id"
  many :discussions, :foreign_key => "focus_id"
end
