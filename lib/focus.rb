# A lightweight MongoMapper plugin that adds Discussion to the model -- the model becomes the focus
module Focus
  # Build the MM associations and callbacks
  def self.included(base)
    base.class_eval do
      key :conversation_id, ObjectId
      key :discussion_ids, Array
      
      # this is the primary thread for a target
      # one :conversation, :class_name => "Discussion"
      
      # other discussions where the Asset is the focus
      many :discussions, :in => :discussion_ids
      
      before_save :set_focus
      before_destroy :remove_focus
    end
    
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  # Class Methods!
  module ClassMethods
  end
  
  # Instance Methods!
  module InstanceMethods
    # Association assignment, also caches the Discussion
    def conversation=(discussion)
      discussion.save if discussion.new?
      @conversation = discussion
      self.conversation_id = discussion.id
    end
    
    # Lazy load and cache the conversation
    def conversation
      @conversation ||= Discussion.find(self.conversation_id)
    end
    
    # Ensures that the association can be reversed
    def set_focus
      unless conversation.nil?
        conversation.focus_id = self.id
        conversation.focus_type = self.class.name
        conversation.save if conversation.changed?
      end
      
      discussions.each do |discussion|
        discussion.focus_id = self.id
        discussion.focus_type = self.class.name
        discussion.save if discussion.changed?
      end
    end
    
    def remove_focus
      unless conversation.nil?
        conversation.focus_id = nil
        conversation.focus_type = ""
        conversation.save if conversation.changed?
      end
      
      discussions.each do |discussion|
        discussion.focus_id = nil
        discussion.focus_type = ""
        discussion.save if discussion.changed?
      end
    end
    
    # A way to aggregate tags up to a focus.  Take this with a grain of salt.
    def tags
      ids = self.discussion_ids + [self.conversation_id]
      tags = Discussion.collection.find({ :_id => { '$in' => ids } }, { :fields => [ :tags ] }).to_a
      
      tags = tags.collect{ |doc| doc['tags'] }.flatten

      counted_tags = Hash.new(0)
      tags.each{ |tag| counted_tags[tag] += 1 }
      self.tags = counted_tags.sort{ |a, b| b[1] <=> a[1] }.collect{ |tag| tag.first }
      self.save if changed?
      self[:tags]
    end
  end
end
