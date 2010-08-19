class BoardsController < ApplicationController
  def science 
    @board = Board.find_by_title("science")
    @board_stats = @board.stats
    @discussions_list = @board.discussions
    render "show"
  end
  
  def chat 
    @board = Board.find_by_title("chat")
    @board_stats = @board.stats
    @discussions_list = @board.discussions
    render "show"
  end
  
  def help
    @board = Board.find_by_title("help")
    @board_stats = @board.stats
    @discussions_list = @board.discussions
    render "show"
  end
end
