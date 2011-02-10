class Board
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  attr_accessible :title
  
  key :_type, String
  key :title, String, :required => true
  
  many :discussions, :foreign_key => :focus_id
  many :sub_boards, :foreign_key => :board_id
  
  before_validation :slugify_title
  
  %w(help science chat).each do |title|
    self.class.send(:define_method, title.to_sym) do
      by_title title
    end
  end
  
  def self.by_title(title)
    find_by_title(title)
  end
  
  def recent_discussions(*args)
    opts = { :page => 1,
             :per_page => 10,
             :for_user => nil,
             :by_user => false
           }.update(args.extract_options!)
    
    cursor = Discussion.sort(:updated_at.desc).where(:focus_id => self.id)
    cursor = cursor.where(:author_ids => opts[:for_user].id) if opts[:for_user] && opts[:by_user]
    cursor.paginate(:page => opts[:page], :per_page => opts[:per_page])
  end
  
  def slugify_title
    return unless changed? && changes.include?('title')
    self.title = self.title.parameterize('_')
  end
  
  def pretty_title
    self.title.titleize
  end
  
  def new_discussion_path(*args)
    new_board_discussion_path(self.title, args.extract_options!)
  end
  
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    erase_default_options_from(options)
    send("#{ self.title }_board_discussion_path", nil, args.first.zooniverse_id, options)
  end
  
  def path(*args)
    options = args.extract_options!
    erase_default_options_from(options)
    send("#{ self.title }_board_path", options)
  end
  
  def conversation_path(*args)
    raise NotImplementedError
  end
  
  protected
  
  def erase_default_options_from(options)
    options.delete(:page) if options[:page] == 1
    options.delete(:per_page) if options[:per_page] == 10
    options
  end
end
