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
  end
end
