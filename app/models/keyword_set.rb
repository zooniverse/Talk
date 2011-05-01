# A dynamic collection of Asset built by Tag and created by a User
class KeywordSet < AssetSet
  zoo_id :prefix => "C", :sub_id => "L"
  before_save :downcase_tags
  
  # Since we're "overriding" this association, we need to make sure mongomapper doesn't try to reload it
  self.associations.delete "assets"
  
  # Replaces a static 1-to-many associations by selecting assets that match the Tags in the KeywordSet
  # @option *args [Fixnum] :page (1) The page of Assets to find
  # @option *args [Fixnum] :per_page (10) The number of Assets per page
  def assets(*args)
    Asset.with_keywords(self.tags, args.extract_options!)
  end
  
  # Selects the most recently created KeywordSets
  # @param [Fixnum] limit The number of KeywordSets to find
  def self.recent(limit = 10)
    KeywordSet.limit(limit).sort(:created_at.desc).all
  end
  
  # Freezes this KeywordSet to a static AssetSet
  def convert_to_static!
    self.asset_ids = assets(:per_page => 0).map(&:_id)
    self.tags = self.keywords
    self.zooniverse_id = nil
    self.destroy
    
    new_self = AssetSet.create(self.to_mongo)
    new_self.set_focus
    Discussion.collection.update({ :_id => self.conversation_id }, { :$set => { :subject => new_self.zooniverse_id } })
    Comment.collection.update({ :focus_id => self._id }, { :$set => { :focus_type => "AssetSet" } })
    Tagging.collection.update({ :focus_id => self._id }, { :$set => { :focus_type => "AssetSet" } })
    new_self
  end
  
  # Ensures the keywords are cleanly formatted
  def downcase_tags
    self.tags = self.tags.map{ |tag| tag.downcase.strip }
  end
  
  # Counts the number of Assets in this KeywordSet
  def asset_count
    assets(:per_page => 1).total_entries
  end
end
