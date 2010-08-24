# A dynamic collection of Asset built by tag and created by a User
class LiveCollection
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  
  zoo_id :prefix => "C", :sub_id => "S"
  key :name, String, :required => true
  key :description, String
  include Taggable
  
  # tag filters to build this collection
  key :tags, Array, :required => true
  timestamps!
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  # Finds assets that match the tags in the LiveCollection
  #   e.g. live_collection.assets(:page => 1, :per_page => 5)
  def assets(*args)
    options = { :page => 0, :per_page => 10 }.update args.extract_options!
    results = Comment.search "focus_type:Asset tags:#{ self.tags.join(' ') }", :limit => 10_000, :collapse => :focus_id
    results = results[ options[:page] * options[:per_page], options[:per_page] ]
    results.map{ |result| Asset.find(result[:focus_id]) }
  end
  
  # Bypasses the Focus#tags aggregation
  def tags
    self[:tags]
  end
  
  def self.most_recent(limit = 10)
    LiveCollection.limit(limit).sort(['created_at', -1]).all
  end
  
  def self.trending(limit = 10)
    discussions = Discussion.collection.group([:focus_id],
      { :focus_type => "LiveCollection" },
      { :score => 0 },
      <<-JS
        function(obj, prev) {
          prev.count += obj.number_of_comments * obj.number_of_users;
        }
      JS
    )
    
    discussions = discussions.result[0, limit].sort{ |a, b| b['score'] <=> a['score'] }
    discussions.map{ |key, val| LiveCollection.find(key['focus_id']) }
   end
end
