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
      before_destroy :remove_focus
    end
    
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  # Class Methods!
  module ClassMethods
    # selects the most recently 'popular' focii
    #  Popularity = Number_of_Comments * Number_of_Users
    def trending(limit = 10)
      discussions = Discussion.collection.group([:focus_id],
        { :focus_type => self.name, :created_at => { "$gt" => Time.now.utc - 1.week } },
        { :score => 0 },
        <<-JS
          function(obj, prev) {
            prev.score += obj.number_of_comments * obj.number_of_users;
          }
        JS
      )

      discussions = discussions[0, limit].sort{ |a, b| b['score'] <=> a['score'] }
      discussions.map{ |key, val| self.find(key['focus_id']) }
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
        conversation.save if conversation.changed?
      end
      
      discussions.each do |discussion|
        discussion.focus_id = self.id
        discussion.focus_type = self.class.name
        discussion.save if discussion.changed?
      end
    end
    
    # Sets orphaned discussions to be unfocused (could become dependent-destroy)
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
    
    # Adds a conversation to all Focii
    def build_conversation
      self.conversation ||= Discussion.new(:subject => self.zooniverse_id)
      self.save if self.changed?
    end
  end
end
