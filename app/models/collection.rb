# A user owned and curated collection of Asset
class Collection
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
  
  # Finds the most recent Collections
  def self.most_recent(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    Collection.sort(:created_at.desc).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  # Finds the most recent assets added to this Collection
  def most_recent_assets(limit = 10)
    return [] if asset_ids.empty?
    self.asset_ids.reverse[0, limit].map{ |id| Asset.find(id) }
  end
  
  # Finds collections containing an asset
  #  Collection.with_asset asset, :page => 2, :per_page => 8
  def self.with_asset(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    opts[:per_page] = opts[:limit] if opts.has_key?(:limit)
    Collection.sort(:created_at.desc).where(:asset_ids => args.first.id).paginate :page => opts[:page], :per_page => opts[:per_page]
  end
  
  def self.with_keywords(*args)
    opts = { :per_page => 20, :page => 1, :order => :created_at.desc }.update(args.extract_options!)
    args = args.collect{ |arg| arg.split }.flatten
    return [] if args.blank?
    
    Collection.where(:tags.all => args).paginate(:page => opts[:page], :per_page => opts[:per_page])
  end
  
  def asset_count
    asset_ids.length
  end
end