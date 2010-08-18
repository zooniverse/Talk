# A user owned and curated collection of Asset
class Collection
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  
  zoo_id :prefix => "C", :sub_id => "S"
  key :name, String, :required => true
  key :description, String
  key :tags, Array
  timestamps!
  
  key :asset_ids, Array
  many :assets, :in => :asset_ids
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  def self.most_recent (no=10)
    Collection.limit(no).sort(['created_at', -1]).all(:created_at.gt => Time.now - 1.day)
  end
  
end
