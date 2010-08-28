# A collection of Discussion which may or may not have a Focus
class Board
  include MongoMapper::Document
  attr_accessor :current_page, :total_pages
  
  key :title, String, :required => true
  key :description, String, :required => true
  key :discussion_ids, Array
  
  many :discussions, :in => :discussion_ids
  
  %w(help science chat).each do |title|
    self.class.send(:define_method, title.to_sym) do |*args|
      by_title(title, *args)
    end
  end
  
  # Finds a Board by title with pagination
  #  Board.by_title "science", :page => 2, :per_page => 10
  def self.by_title(*args)
    opts = args.extract_options!
    where(:title => args.first).first.by_page(opts)
  end
  
  # Paginates board discussions
  #  science_board = Board.science :page => 3
  #  science_board.total_pages  =>  15
  #  science_board.current_page =>  <discussions...>
  def by_page(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    
    max = self.discussion_ids.length
    start = [ opts[:per_page] * (opts[:page] - 1), max ].min
    length = [opts[:per_page], max - start].min
    
    ids = self.discussion_ids.reverse[ start, length ]
    @current_page = ids.map{ |id| Discussion.find(id) }
    @total_pages = (discussion_ids.length / opts[:per_page].to_f).ceil
    self
  end
  
  # The number of comments in this board
  def number_of_comments
    Comment.count(:discussion_id.in => self.discussion_ids)
  end
end
