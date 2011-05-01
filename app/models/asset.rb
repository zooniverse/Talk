# The classification object
# 
# Generally referred to as an "Object"
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
  
  # Selects the most recently mentioned Assets (ie AM0000BLAH was mentioned in a Comment)
  # @param [Fixnum] limit The number of Assets to find
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
  
  # Selects the most recently discussed Assets (ie the Assets with the newest Comments)
  # @param *args [Array] Pagination options
  # @option *args [Fixnum] :page (1) The page of Assets to find
  # @option *args [Fixnum] :per_page (10) The number of Assets per page
  def self.recent(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    self.sort(:updated_at.desc).paginate(opts)
  end
  
  # Selects Assets that match all given keywords (boolean AND)
  # @param *args [Array] Pagination options
  # @option *args [Fixnum] :page (1) The page of Assets to find
  # @option *args [Fixnum] :per_page (10) The number of Assets per page
  def self.with_keywords(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    args = args.first if args.first.is_a? Array
    return [] if args.blank?
    
    self.sort(:updated_at.desc).where(:tags.all => args).paginate(opts)
  end
  
  # Selects AssetSets that contain this collection
  # @param [Fixnum] limit The number of AssetSets to find
  def collections(limit = 10)
    collections = AssetSet.with_asset self, :limit => limit
  end
  
  # Selects Comments mentioning this asset
  # @param [Fixnum] limit The number of Comments to find
  def mentions(limit = 10)
    Comment.mentioning(self, limit)
  end
  
  # Counts Comments mentioning this Asset
  def count_mentions
    Comment.count_mentions(self)
  end
  
  # Counts AssetSets that contain this Asset
  def count_collections
    AssetSet.count(:asset_ids => self.id)
  end
  
  # The path to start a new discussion about this Asset
  # @param [Array] *args Arguments to pass into the url helper
  def new_discussion_path(*args)
    new_object_discussion_path(self.zooniverse_id, args.extract_options!)
  end
  
  # The path to a discussion about this Asset
  # @param [Array] *args The Discussion
  # @option *args [Hash] * Arguments to pass into the url helper
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    object_discussion_path(self.zooniverse_id, args.first.zooniverse_id, options)
  end
  
  # The path to the conversation about this Asset
  # @param [Array] *args Arguments to pass into the url helper
  def conversation_path(*args)
    options = args.extract_options!
    options.delete(:page) if options[:page] == 1
    object_path(self.zooniverse_id, options)
  end
end
