# A lightweight MongoMapper plugin that adds Discussion to the model -- the model becomes the focus
module Focus
  extend ActiveSupport::Concern
  # Build the MM associations and callbacks
  
  included do
    key :conversation_id, ObjectId
    key :discussion_ids, Array
    key :popularity, Integer, :default => 0
    many :discussions, :in => :discussion_ids
    
    after_create :build_conversation
    before_save :set_focus
  end
  
  # Class Methods!
  module ClassMethods
    # Selects the most 'popular' Focii
    # @option *args [Fixnum] :page (1) The page of Focii to find
    # @option *args [Fixnum] :per_page (5) The number of Focii per page
    def trending(*args)
      opts = { :page => 1, :per_page => 5 }.update(args.extract_options!)
      self.sort(:popularity.desc).paginate(opts)
    end
  end
  
  # Association assignment, also caches the Discussion
  # @param discussion [Discussion] The Discussion that is the conversation for this Focus
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
      conversation.focus_base_type = self.is_a?(KeywordSet) ? "AssetSet" : self.class.name
      conversation.save if conversation.changed?
    end
    
    discussions.each do |discussion|
      discussion.focus_id = self.id
      discussion.focus_type = self.class.name
      discussion.focus_base_type = self.is_a?(KeywordSet) ? "AssetSet" : self.class.name
      discussion.save if discussion.changed?
    end
  end
  
  # Adds a conversation to all Focii
  def build_conversation
    self.conversation ||= Discussion.new(:subject => self.zooniverse_id)
    self.save if self.changed?
  end
  
  # Selects Tags for this Focus
  # @param limit [Fixnum] The number of Tags to find
  def keywords(limit = 10)
    Tag.for_focus(self, limit).collect{ |t| t.name }
  end
  
  # Denormalizes trending score to this Focus
  def update_popularity
    fresh_discussions = Discussion.collection.find({ :focus_id => self.id }, { :fields => :popularity }).to_a
    new_popularity = fresh_discussions.collect{ |d| d['popularity'] }.sum
    self.set(:popularity => new_popularity) unless new_popularity == self.popularity
  end
  
  # Archive and destroy this Focus
  # @param destroying_user [User] the User destroying this Focus
  def archive_and_destroy_as(destroying_user)
    archive = Archive.new({
      :kind => self.class.name,
      :original_id => self.id,
      :zooniverse_id => self.zooniverse_id,
      :user_id => self.user_id,
      :destroying_user_id => destroying_user.id
    })
    
    original = self.to_mongo
    original['conversation'] = self.conversation.to_embedded_hash
    original['discussions'] = self.discussions.collect(&:to_embedded_hash)
    archive.original_document = original
    
    if archive.save
      self.conversation.destroy
      self.discussions.each(&:destroy)
      self.destroy
    end
  end
end
