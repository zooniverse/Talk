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
  
  def self.by_title(*args)
    opts = args.extract_options!
    where(:title => args.first).first.by_page(opts)
  end
  
  def by_page(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    ids = self.discussion_ids.reverse[ opts[:per_page] * (opts[:page] - 1), opts[:per_page] ]
    @current_page = ids.map{ |id| Discussion.find(id) }
    @total_pages = (discussion_ids.length / opts[:per_page].to_f).ceil
    self
  end
  
  def number_of_comments
    Comment.count(:discussion_id.in => self.discussion_ids)
  end
end
