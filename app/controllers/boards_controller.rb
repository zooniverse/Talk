class BoardsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:science, :help, :chat]
  respond_to :js, :only => [:browse, :show]
  
  def show
    show_by_title(params[:board_id])
  end
  
  %w(help science chat).each do |title|
    define_method(title.to_sym) do
      show_by_title title
    end
  end
  
  def show_by_title(title)
    default_params :page => 1, :per_page => 10, :by_user => false
    @board = Board.by_title(title)
    return not_found unless @board
    
    @board_options = { :page => @page, :per_page => @per_page, :by_user => @by_user }
    @discussions = @board.recent_discussions({ :for_user => current_zooniverse_user }.merge(@board_options))
    
    respond_with(@board) do |format|
      format.html { render "show" }
      format.js do
        render :update do |page|
          page['#discussions .list'].html(render :partial => "discussions")
        end
      end
    end
  end
  
  def browse
    @boards = [Board.help, Board.science, Board.chat]
    
    respond_with(@boards) do |format|
       format.js { render :partial => "browse" }
     end
  end
end
