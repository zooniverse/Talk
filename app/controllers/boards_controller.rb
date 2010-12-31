class BoardsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:science, :help, :chat]
  respond_to :js, :only => [:browse]
  
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
    return not_found unless @board
    
    @discussions = @board.discussions.paginate :page => @page, :per_page => @per_page
    render "show"
  end
  
  def browse
    @boards = [Board.help, Board.science, Board.chat]
    
    respond_with(@boards) do |format|
       format.js { render :partial => "browse" }
     end
  end
end
