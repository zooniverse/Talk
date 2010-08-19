class BoardsController < ApplicationController
  
  def science 
    @board = Board.find_by_title("Science")
    @discussions_list = @board.discussions
    render "show"
  end
  
  def chat 
    @board = Board.find_by_title("Chat")
    @discussions_list = @board.discussions
    render "show"
  end
  
  def help
    @board = Board.find_by_title("Help")
    @discussions_list = @board.discussions
    render "show"
  end

end
