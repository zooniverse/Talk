# A collection of Discussion which may or may not have a Focus
class Board
  include Rails.application.routes.url_helpers
  include MongoMapper::Document
  attr_accessible :title, :description
  
  key :title, String, :required => true
  key :description, String, :required => true
  key :discussion_ids, Array
  
  many :discussions, :in => :discussion_ids
  
  %w(help science chat).each do |title|
    self.class.send(:define_method, title.to_sym) do
      by_title title
    end
  end
  
  def self.by_title(title)
    find_by_title(title)
  end
  
  # The number of comments in this board
  def number_of_comments
    Comment.count(:discussion_id.in => self.discussion_ids)
  end
  
  def recent_discussions(*args)
    opts = { :page => 1,
             :per_page => 10,
             :for_user => nil,
             :by_user => false
           }.update(args.extract_options!)
    
    cursor = Discussion.sort(:updated_at.desc).where(:_id.in => self.discussion_ids)
    cursor = cursor.where(:author_ids => opts[:for_user].id) if opts[:for_user] && opts[:by_user]
    cursor.paginate(:page => opts[:page], :per_page => opts[:per_page])
  end
  
  def pull_discussion(discussion)
    Board.collection.update({ :_id => self.id }, {
      :$pull => { :discussion_ids => discussion.id }
    })
  end
  
  def new_discussion_path(*args)
    new_board_discussion_path(self.title, args.extract_options!)
  end
  
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    query_string = options.any? ? "?#{ options.to_query }" : ""
    "/#{ self.title.downcase }/discussions/#{ args.first.zooniverse_id }#{ query_string }"
  end
  
  def conversation_path(*args)
    raise NotImplementedError
  end
end
