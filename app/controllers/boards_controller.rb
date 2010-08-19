class BoardsController < ApplicationController
  def science 
    @board = Board.find_by_title("science")
    @discussions_list = @board.discussions
    render "show"
  end
  
  def chat 
    @board = Board.find_by_title("chat")
    @discussions_list = @board.discussions
    render "show"
  end
  
  def help
    @board = Board.find_by_title("help")
    @discussions_list = @board.discussions
    render "show"
  end
end
