# A collection of Discussion which may or may not have a Focus
class Board
  include MongoMapper::Document
  attr_accessor :current_page, :total_pages
  
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
end
