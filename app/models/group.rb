# A semi-dynamic collection of Assets built by group_id
class Group
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  include Focus
  
  key :zooniverse_id, String
  key :tags, Array
  timestamps!
  
  many :assets
  
  def new_discussion_path(*args)
    new_group_discussion_path(self.zooniverse_id, args.extract_options!)
  end
  
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    group_discussion_path(self.zooniverse_id, args.first.zooniverse_id, options)
  end
  
  def conversation_path(*args)
    options = args.extract_options!
    options.delete(:page) if options[:page] == 1
    group_path(self.zooniverse_id, options)
  end
end
