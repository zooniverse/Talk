# A user owned and curated collection of Asset
class Collection
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  include Taggable
  
  zoo_id :prefix => "C", :sub_id => "S"
  key :name, String, :required => true
  key :description, String
  timestamps!
  
  key :asset_ids, Array
  many :assets, :in => :asset_ids
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  def self.most_recent (no=10)
    Collection.limit(no).sort(['created_at', -1]).all
  end
  
  def most_recent_assets(no=10)
    self.assets[0..no-1]
  end
  
  def most_recent_comments(no=10)
    discussionIds=self.discussions.collect{|d| d.id}
    Comment.where(:discussion_id.in => discussionIds).limit(no).sort(['created_at',-1]).all
  end
  
  # Finds collections containing an asset
  def self.with_asset(asset, *args)
    opts = { :limit => 10, :order => ['created_at', -1] }
    opts = opts.update(args.first) unless args.first.nil?
    
    Collection.limit(opts[:limit]).sort(opts[:order]).all(:asset_ids => asset.id)
  end
  
  def self.trending(limit = 10)
    discussions = Discussion.collection.group([:focus_id],
    { :focus_type => "Collection" },
      { :score => 0 },
      <<-JS
        function(obj, prev) {
          prev.score += obj.number_of_comments * obj.number_of_users;
        }
      JS
    )
    
    discussions = discussions[0, limit].sort{ |a, b| b['score'] <=> a['score'] }
    discussions.map{ |key, val| Collection.find(key['focus_id']) }
  end
end