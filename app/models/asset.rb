class Asset
  include MongoMapper::Document
  
  key :zooniverse_id, String, :required => true
  key :location, String, :required => true
  key :thumbnail_location, String, :required => true
  key :coords, Array
  key :size, Array
  key :tags, Array
  
  one :conversation, :class_name => "Discussion", :foreign_key => "focus_id" # this is the primary thread for a target
  many :discussions, :foreign_key => "focus_id" # other discussions where the Asset is the focus
end
