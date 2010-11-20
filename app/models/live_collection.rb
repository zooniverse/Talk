# A dynamic collection of Asset built by tag and created by a User
class LiveCollection
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  
  zoo_id :prefix => "C", :sub_id => "L"
  key :name, String, :required => true
  key :description, String
  
  # tag filters to build this collection
  key :tags, Array, :required => true
  timestamps!
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  before_save :downcase_tags
  
  # Finds assets that match the tags in the LiveCollection
  #   e.g. live_collection.assets(:page => 1, :per_page => 5)
  def assets(*args)
    Asset.with_keywords(self.tags, args.extract_options!)
  end
  
  # Finds the most recently created LiveCollections
  def self.most_recent(limit = 10)
    LiveCollection.limit(limit).sort(:created_at.desc).all
  end
  
  def downcase_tags
    self.tags = self.tags.map(&:downcase)
  end
end
