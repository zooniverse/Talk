# A collection of Discussion which may or may not have a Focus
class Board
  include MongoMapper::Document
  
  key :title, String, :required => true
  key :description, String, :required => true
  key :discussion_ids, Array
  
  many :discussions, :in => :discussion_ids
end
