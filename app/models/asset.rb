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
  timestamps!
  
  # selects the most recently mentioned (ie AM0000BLAH was mentioned in a comment) assets
  def self.most_recently_mentioned(limit = 10)
    cursor = Comment.collection.find({ :mentions => { "$type" => 2 } }).sort([:created_at, :desc])
    asset_ids = {}
    
    while asset_ids.length < limit && cursor.has_next?
      doc = cursor.next_document
      doc['mentions'].each do |zoo_id|
        asset_ids[zoo_id] = 1
      end
    end
    
    asset_ids.map{ |zoo_id, d_id | Asset.find_by_zooniverse_id(zoo_id) }
  end
  
  # selects the most recently discussed assets (ie the assets with the newest comments )
  def self.most_recently_commented_on(limit = 10)
    cursor = Discussion.collection.find({ :focus_type => "Asset" }).sort([:created_at, :desc])
    asset_ids = {}
    
    while asset_ids.length < limit && cursor.has_next?
      doc = cursor.next_document
      asset_ids[ doc['focus_id'] ] = 1
    end
    
    asset_ids.map{ |focus_id, d_id| Asset.find(focus_id) }
  end
  
  # Finds assets that match the given keywords
  #   e.g. Asset.by_keywords('tag1', 'tag2', :page => 1, :per_page => 5)
  def self.with_keywords(*args)
    opts = { :page => 0, :per_page => 10 }.update(args.extract_options!)
    args = args.first if args.first.is_a? Array
    criteria = args.collect{ |tag| { :"taggings.#{tag}".exists => true } }.inject :merge
    order = args.collect{ |tag| "taggings.#{tag} desc" }.join(', ')
    results = Asset.where(criteria).sort(order).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Find collections containing this asset
  def collections
    collections = Collection.with_asset(self)
  end
  
  # Find discussions mentioning this asset
  def mentions
    mentions = Discussion.mentioning(self)
  end
end
