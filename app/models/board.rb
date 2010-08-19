# A collection of Discussion which may or may not have a Focus
class Board
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :description, String, :required => true
  key :discussion_ids, Array
  
  many :discussions, :in => :discussion_ids
  
  # the science Board
  def self.science
    find_by_title("Science")
  end
  
  # the help Board
  def self.help
    find_by_title("Help")
  end
  
  # the chat Board
  def self.chat
    find_by_title("Chat")
  end
  
  # FIXME
  def number_of_users
    2
  end
  
  # FIXME
  def number_of_comments
    3
  end
end
