# A dynamic collection of Asset built by tag and created by a User
class LiveCollection
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  
  zoo_id :prefix => "C", :sub_id => "S"
  key :name, String, :required => true
  key :description, String
  
  # tag filters to build this collection
  key :tags, Array, :required => true
  timestamps!
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  def assets(*args)
    options = { :page => 0, :per_page => 10 }
    options = options.update(args.first) unless args.first.nil?
    
    Asset.where(:tags.all => self.tags).skip(options[:page] * options[:per_page]).limit(options[:per_page]).all
  end
  
  def tags
    self[:tags]
  end
end
