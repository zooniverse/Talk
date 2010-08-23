# A collection of Discussion which may or may not have a Focus
class Board
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :description, String, :required => true
  key :discussion_ids, Array
  
  many :discussions, :in => :discussion_ids
  
  # the science Board
  def self.science
    find_by_title("science")
  end
  
  # the help Board
  def self.help
    find_by_title("help")
  end
  
  # the chat Board
  def self.chat
    find_by_title("chat")
  end
  
  def stats 
    r = {:number_of_users=>0, :number_of_comments=>0}
    self.discussions.each do |d|
       r[:number_of_users]= r[:number_of_users] +d.number_of_users
       r[:number_of_comments]= r[:number_of_comments] +d.number_of_comments
    end
    r
  end
end
