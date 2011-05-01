# A list of Discussions by category
class Board
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  attr_accessible :pretty_title
  
  key :_type, String
  key :title, String, :required => true
  key :pretty_title, String, :required => true
  
  many :discussions, :foreign_key => :focus_id
  many :sub_boards, :foreign_key => :board_id
  
  before_validation :slugify_title
  
  # Define convenience methods
  %w(help science chat).each do |title|
    self.class.send(:define_method, title.to_sym) do
      by_title title
    end
  end
  
  # Shortcut to find a Board by title
  def self.by_title(title)
    find_by_title(title)
  end
  
  # Selects the most recent Discussions in this Board
  # @param *args [Array] Options
  # @option *args [Fixnum] :page (1) The page of Discussions to find
  # @option *args [Fixnum] :per_page (10) The number of Discussions per page
  # @option *args [Boolean] :by_user (false) Limits results to Discussions including a Comment by the given User
  # @option *args [User] :for_user The User for which Discussions are being found
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
  
  # A parameterized title for this Board
  def slugify_title
    return unless changed? && changes.include?('pretty_title')
    self.title = self.pretty_title.parameterize('_')
  end
  
  # The path to start a new discussion in this Board
  # @param [Array] *args Arguments to pass into the url helper
  def new_discussion_path(*args)
    new_board_discussion_path(self.title, args.extract_options!)
  end
  
  # The path to a discussion in this Board
  # @param [Array] *args The Discussion
  # @option *args [Hash] * Arguments to pass into the url helper
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    erase_default_options_from(options)
    send("#{ self.title }_board_discussion_path", nil, args.first.zooniverse_id, options)
  end
  
  # The path to this Board
  # @option *args [Hash] * Arguments to pass into the url helper
  def path(*args)
    options = args.extract_options!
    erase_default_options_from(options)
    send("#{ self.title }_board_path", options)
  end
  
  # Boards don't have conversations
  def conversation_path(*args)
    raise NotImplementedError
  end
  
  protected
  
  # Remove options if they're set to default values
  def erase_default_options_from(options)
    options.delete(:page) if options[:page] == 1
    options.delete(:per_page) if options[:per_page] == 10
    options
  end
end
