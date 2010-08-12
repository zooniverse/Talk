# Kind of a meta thing right now.  
# Pretty sure we're going to use this for discussion of Tags or groups of Tags
class Tag
  include MongoMapper::Document
  include Focus
  
  # for our meta discussion about tags or collections of tags
  key :tags, Array, :required => true
  
  # for caching?
  key :asset_ids, Array
  
  many :assets, :in => :asset_ids
end
