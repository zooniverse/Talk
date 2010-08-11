class Asset
  include MongoMapper::Document
  
  key :zooniverse_id, String, :required => true
  key :location, String, :required => true
  key :thumbnail_location, String, :required => true
  key :coords, Array
  key :size, Array
  key :tags, Array
  
  one :conversation, :class_name => "Discussion", :foreign_key => "focus_id"
  many :discussions, :foreign_key => "focus_id"
end
