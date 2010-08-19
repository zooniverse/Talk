class BoardsController < ApplicationController
  def science 
    @per_page = params[:per_page]
    @page= params[:page]
    
    @per_page ||= 10
    @page ||= 1    
    
    @per_page=@per_page.to_i
    @page=@page.to_i
    
    @board = Board.find_by_title("science")
    @board_stats = @board.stats
    @discussions_list = @board.discussions.paginate :per_page=>@per_page, :page=>@page
    @number_of_pages = (@board.discussion_ids.count/@per_page).floor 
    
    render "show"
  end
  
  def chat 
    @per_page = params[:per_page]
    @page= params[:page]
    @per_page ||= 10
    @page ||= 1
    @per_page=@per_page.to_i
    @page=@page.to_i
    
    @board = Board.find_by_title("chat")
    @board_stats = @board.stats
    @discussions_list = @board.discussions.paginate :per_page=>@per_page, :page=>@page
    @number_of_pages = (@board.discussion_ids.count/@per_page).floor 
    render "show"
  end
  
  def help
    @per_page = params[:per_page]
    @page= params[:page]
    @per_page ||= 10
    @page ||= 1
    
    @per_page=@per_page.to_i
    @page=@page.to_i
    
    @board = Board.find_by_title("help")
    @board_stats = @board.stats
    @discussions_list = @board.discussions.paginate :per_page=>@per_page, :page=>@page
    @number_of_pages = (@board.discussion_ids.count/@per_page).floor 
    render "show"
  end
end
