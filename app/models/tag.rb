class Tag
  include MongoMapper::Document
  
  key :name, String
  key :count, Integer, :default => 0
  
  def self.for_focus(focus, limit = 10)
    Tagging.limit(limit).sort(:count.desc).all(:focus_id => focus.id)
  end
  
  def self.for_discussion(discussion, limit = 10)
    Tagging.limit(limit).sort(:count.desc).all(:discussion_ids => discussion.id)
  end
end
