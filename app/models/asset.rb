# The object being classified
class Asset
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  include Focus
  
  key :zooniverse_id, String, :required => true
  key :location, String, :required => true
  key :thumbnail_location, String, :required => true
  key :coords, Array
  key :size, Array
  key :group_id, ObjectId
  key :tags, Array
  timestamps!
  
  belongs_to :group
  
  # selects the most recently mentioned (ie AM0000BLAH was mentioned in a comment) assets
  def self.recently_mentioned(limit = 10)
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
  def self.recent(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    self.sort(:updated_at.desc).paginate(opts)
  end
  
  # Finds assets that match the given keywords
  #   e.g. Asset.by_keywords('tag1', 'tag2', :page => 1, :per_page => 5)
  def self.with_keywords(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    args = args.first if args.first.is_a? Array
    return [] if args.blank?
    
    self.sort(:updated_at.desc).where(:tags.all => args).paginate(opts)
  end
  
  # Find collections containing this asset
  def collections(limit = 10)
    collections = Collection.with_asset self, :limit => limit
  end
  
  # Finds comments mentioning this asset
  def mentions(limit = 10)
    mentions = Comment.mentioning(self, limit)
  end
  
  # Counts comments mentioning this asset
  def count_mentions
    Comment.count_mentions(self)
  end
  
  # Counts collections with this asset
  def count_collections
    Collection.count(:asset_ids => self.id)
  end
  
  def new_discussion_path(*args)
    new_object_discussion_path(self.zooniverse_id, args.extract_options!)
  end
  
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    object_discussion_path(self.zooniverse_id, args.first.zooniverse_id, options)
  end
  
  def conversation_path(*args)
    options = args.extract_options!
    options.delete(:page) if options[:page] == 1
    object_path(self.zooniverse_id, options)
  end
end
