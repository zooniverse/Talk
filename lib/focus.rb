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
      
      after_create :build_conversation
      before_save :set_focus
    end
    
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  # Class Methods!
  module ClassMethods
    # selects the most 'popular' focii
    def trending(limit = 10)
      cursor = Discussion.where(:focus_base_type => self.name).sort(:popularity.desc).only(:focus_id).find_each
      focii = {}
      
      while focii.length < limit && cursor.has_next?
        doc = cursor.next_document
        focii[ doc['focus_id'] ] = 1
      end
      
      focii.keys.map{ |f_id| self.find(f_id) }
    end
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
        conversation.focus_base_type = self.is_a?(LiveCollection) ? "Collection" : self.class.name
        conversation.save if conversation.changed?
      end
      
      discussions.each do |discussion|
        discussion.focus_id = self.id
        discussion.focus_type = self.class.name
        discussion.focus_base_type = self.is_a?(LiveCollection) ? "Collection" : self.class.name
        discussion.save if discussion.changed?
      end
    end
    
    # Adds a conversation to all Focii
    def build_conversation
      self.conversation ||= Discussion.new(:subject => self.zooniverse_id)
      self.save if self.changed?
    end
    
    def keywords(limit = 10)
      Tag.for_focus(self, limit).collect{ |t| t.name }
    end
  end
end
