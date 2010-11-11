class BoardsController < ApplicationController
  respond_to :js, :only => [:list_for_browser]
  
  def show
    show_by_title(params[:board_id])
  end
  
  %w(help science chat).each do |title|
    define_method(title.to_sym) do
      show_by_title title
    end
  end
  
  def show_by_title(title)
    default_params :page => 1, :per_page => 9
    @board = Board.by_title(title)
    @discussions = @board.discussions.paginate :page => @page, :per_page => @per_page
    
    render "show"
  end
  
  def list_for_browser
    @boards = [Board.help, Board.science, Board.chat]
    
    respond_with(@boards) do |format|
       format.js { render :partial => "list_for_browser" }
     end    
  end
end
