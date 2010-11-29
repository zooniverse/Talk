# A dynamic collection of Asset built by tag and created by a User
class LiveCollection < Collection
  zoo_id :prefix => "C", :sub_id => "L"
  before_save :downcase_tags
  
  # Since we're "overriding" this association, we need to make sure mongomapper doesn't try to reload it
  self.associations.delete "assets"
  
  # Finds assets that match the tags in the LiveCollection
  #   e.g. live_collection.assets(:page => 1, :per_page => 5)
  def assets(*args)
    Asset.with_keywords(self.tags, args.extract_options!)
  end
  
  # Finds the most recently created LiveCollections
  def self.most_recent(limit = 10)
    LiveCollection.limit(limit).sort(:created_at.desc).all
  end
  
  # Freezes this live collection as a static collection
  def convert_to_static!
    self.asset_ids = assets(:per_page => 0).map(&:_id)
    self.tags = self.keywords
    self.zooniverse_id = nil
    self.destroy
    
    new_self = Collection.create(self.to_mongo)
    new_self.set_focus
    Discussion.collection.update({ :_id => self.conversation_id }, { :$set => { :subject => new_self.zooniverse_id } })
    Comment.collection.update({ :focus_id => self._id }, { :$set => { :focus_type => "Collection" } })
    Tagging.collection.update({ :focus_id => self._id }, { :$set => { :focus_type => "Collection" } })
    new_self
  end
  
  def downcase_tags
    self.tags = self.tags.map(&:downcase)
  end
end
