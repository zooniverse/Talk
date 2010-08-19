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
  
  # selects the most recently mentioned (ie AM0000BLAH was mentioned in a comment) assets
  def self.most_recently_mentioned(limit = 10)
    cursor = Discussion.collection.find({ :focus_type => "Asset", :mentions => { "$type" => 2 } }).sort(['created_at', -1])
    asset_ids = {}
    
    while asset_ids.length < limit && cursor.has_next?
      doc = cursor.next_document
      doc['mentions'].each do |zoo_id|
        asset_ids[zoo_id] = 1 if zoo_id =~ /^A/
      end
    end
    
    asset_ids.map{ |zoo_id| Asset.find_by_zooniverse_id(zoo_id) }
  end
  
  # selects the most recently discussed assets (ie the assets with the newest comments )
  def self.most_recently_commented_on(limit = 10)
    cursor = Discussion.collection.find({ :focus_type => "Asset" }).sort(['created_at', -1])
    asset_ids = {}
    
    while asset_ids.length < limit && cursor.has_next?
      doc = cursor.next_document
      asset_ids[ doc['focus_id'] ] = 1
    end
    
    asset_ids.map{ |focus_id, d_id| Asset.find(focus_id) }
  end
  
  # selects the most recently 'popular' assets
  #  Popularity = Number_of_Comments * Number_of_Users
  def self.trending(limit = 10)
    discussions = Discussion.collection.group([:focus_id],
      { :focus_type => "Asset", :created_at => { "$gt" => Time.now.utc - 1.week } },
      { :score => 0 },
      <<-JS
        function(obj, prev) {
          prev.score += obj.number_of_comments * obj.number_of_users;
        }
      JS
    )
    
    discussions = discussions[0, limit].sort{ |a, b| b['score'] <=> a['score'] }
    discussions.map{ |key, val| Asset.find(key['focus_id']) }
  end
end
