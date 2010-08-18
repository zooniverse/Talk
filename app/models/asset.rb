# The object being classified
class Asset
  include MongoMapper::Document
  include Focus
  include Taggable
  
  
  key :zooniverse_id, String, :required => true
  key :location, String, :required => true
  key :thumbnail_location, String, :required => true
  key :coords, Array
  key :size, Array
  key :tags, Array
  
  def self.most_recent(no=10)
     Asset.limit(no).sort(['created_at', -1]).all
   end
   
  #selects the most recently mentioned (ie AM0000BLAH was mentioned in a comment) assets
  
  def self.most_recently_mentioned(no=10)
    Asset.all(:zooniverse_id.in => Comment.most_recent(5*no).collect{|c| c.assets}.flatten[0..no-1])
  end
  
  #selects the most recently discussed assets (ie the assets with the newest comments )
  def self.most_recently_(no=10)
    Asset.most_recently_mentioned no
  end
  
end
