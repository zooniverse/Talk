# A User owned and curated collection of Assets
# 
# Generally referred to as a "Collection"
class AssetSet
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  attr_accessible :name, :description, :asset_ids
  
  zoo_id :prefix => "C", :sub_id => "S"
  key :_type, String
  key :name, String, :required => true
  key :description, String
  key :tags, Array
  timestamps!
  
  key :asset_ids, Array
  many :assets, :in => :asset_ids
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  # Selects the most recent AssetSets
  # @param *args [Array] Pagination options
  # @option *args [Fixnum] :page (1) The page of AssetSets to find
  # @option *args [Fixnum] :per_page (10) The number of AssetSets per page
  def self.recent(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    self.sort(:created_at.desc).paginate(opts)
  end
  
  # Selects the most recently added Assets
  # @param [Fixnum] limit The number of Assets to find
  def recent_assets(limit = 10)
    return [] if asset_ids.empty?
    self.asset_ids.reverse[0, limit].map{ |id| Asset.find(id) }
  end
  
  # Selects AssetSets containing an asset
  # @param *args [Array] Pagination options
  # @option *args [Fixnum] :page (1) The page of AssetSets to find
  # @option *args [Fixnum] :per_page (10) The number of AssetSets per page
  def self.with_asset(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    opts[:per_page] = opts[:limit] if opts.has_key?(:limit)
    self.sort(:created_at.desc).where(:asset_ids => args.first.id).paginate(opts)
  end
  
  # Selects AssetSets tagged with the given keywords
  # @param *args [Array] The list of keywords to search for
  # @option *args [Fixnum] :page (1) The page of AssetSets to find
  # @option *args [Fixnum] :per_page (20) The number of AssetSets per page
  def self.with_keywords(*args)
    opts = { :per_page => 20, :page => 1 }.update(args.extract_options!)
    args = args.collect{ |arg| arg.split }.flatten
    return [] if args.blank?
    
    self.sort(:created_at.desc).where(:tags.all => args).paginate(opts)
  end
  
  # Counts the number of Assets in this AssetSet
  def asset_count
    asset_ids.length
  end
  
  # The path to start a new discussion about this AssetSet
  # @param [Array] *args Arguments to pass into the url helper
  def new_discussion_path(*args)
    new_collection_discussion_path(self.zooniverse_id, args.extract_options!)
  end
  
  # The path to a discussion about this AssetSet
  # @param [Array] *args The Discussion
  # @option *args [Hash] * Arguments to pass into the url helper
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    collection_discussion_path(self.zooniverse_id, args.first.zooniverse_id, options)
  end
  
  # The path to the conversation about this AssetSet
  # @param [Array] *args Arguments to pass into the url helper
  def conversation_path(*args)
    options = args.extract_options!
    options.delete(:page) if options[:page] == 1
    collection_path(self.zooniverse_id, options)
  end
end
