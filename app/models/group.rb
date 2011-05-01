# A semi-dynamic collection of Assets built by group_id
class Group
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  include Focus
  
  key :zooniverse_id, String
  key :tags, Array
  timestamps!
  
  many :assets
  
  # The path to start a new discussion about this Group
  # @param [Array] *args Arguments to pass into the url helper
  def new_discussion_path(*args)
    new_group_discussion_path(self.zooniverse_id, args.extract_options!)
  end
  
  # The path to a discussion about this Group
  # @param [Array] *args The Discussion
  # @option *args [Hash] * Arguments to pass into the url helper
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    group_discussion_path(self.zooniverse_id, args.first.zooniverse_id, options)
  end
  
  # The path to the conversation about this Group
  # @param [Array] *args Arguments to pass into the url helper
  def conversation_path(*args)
    options = args.extract_options!
    options.delete(:page) if options[:page] == 1
    group_path(self.zooniverse_id, options)
  end
end
