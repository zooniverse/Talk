# Boards
class BoardsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:science, :help, :chat]
  respond_to :js, :only => [:show, :arrange, :update]
  before_filter :require_privileged_user, :only => [:arrange, :update]
  
  # Show the board
  def show
    show_by_title(params[:board_id])
  end
  
  # Pretty route methods
  %w(help science chat).each do |title|
    define_method(title.to_sym) do
      if params[:sub_board_id].present?
        sub_board params[:sub_board_id], title
      else
        show_by_title title
      end
    end
  end
  
  # Finds a SubBoard
  # @param sub_title [String] The name of the SubBoard
  # @param parent_title [String] The name of the Board
  def sub_board(sub_title, parent_title)
    @parent = Board.by_title parent_title
    return not_found unless @parent
    
    @board = SubBoard.first(:title => sub_title, :board_id => @parent.id)
    return not_found unless @board
    
    @page_title = "#{ @parent.pretty_title } | #{ @board.pretty_title }"
    show_by_title @board.title
  end
  
  # Arranging SubBoards in the list
  def arrange
    params[:positions].each.with_index do |id, index|
      sub_board = SubBoard.first(:id => id, :board_id => params[:id])
      sub_board.set :position => index
    end
    
    flash[:notice] = "Your changes have been saved"
    
    respond_with(nil) do |format|
      format.js do
        render :update do |page|
          page[".wrapper"].prepend(render :partial => "shared/flash", :locals => { :flash => flash })
          page.call "Talk.notice.init"
        end
      end
    end
  end
  
  # Update a (Sub)Board
  def update
    @board = Board.find(params[:id])
    flash[:notice] = []
    flash[:alert] = []
    
    if params[:sub_boards].present? && params[:sub_boards].is_a?(Hash)
      sub_board = nil
      
      params[:sub_boards].each_pair do |id, changes|
        sub_board = if id.match(/^new_/)
          true
        else
          sub_board = SubBoard.find(id)
        end
        
        next unless sub_board
        validated = []
        
        if changes.has_key?(:create) && changes.has_key?(:title) && !changes.has_key?(:destroy)
          sub_board = SubBoard.new(:pretty_title => changes[:title])
          sub_board.parent = @board
          sub_board.position = SubBoard.count(:board_id => @board.id)
          
          if sub_board.save
            flash[:notice] << "#{ sub_board.pretty_title } was created"
          else
            flash[:alert] << [sub_board, "#{ changes[:title] } could not be created"]
          end
        elsif changes.has_key?(:destroy) && !changes.has_key?(:create)
          if sub_board.archive_and_destroy_as(current_zooniverse_user)
            flash[:notice] << "#{ sub_board.pretty_title } was removed"
          else
            flash[:alert] << [sub_board, "#{ sub_board.pretty_title } could not be destroyed"]
          end
        elsif changes.has_key?(:title) && !changes.has_key?(:create)
          sub_board.pretty_title = changes[:title]
          
          if sub_board.save
            flash[:notice] << "#{ sub_board.pretty_title } was updated"
          else
            flash[:alert] << [sub_board, "#{ sub_board.reload.pretty_title }'s title could not be changed to \"#{ changes[:title] }\""]
          end
        end
      end
    end
    
    format_flashes
    
    respond_with(@board) do |format|
      format.js do
        render :update do |page|
          page[".wrapper"].prepend(render :partial => "shared/flash", :locals => { :flash => flash })
          page["#boards"].html(render :partial => "sub_boards")
          page.call "Talk.notice.init"
        end
      end
    end
  end
  
  # Shows a board by title
  def show_by_title(title)
    default_params :page => 1, :per_page => 10, :by_user => false
    @board ||= Board.by_title(title)
    return not_found unless @board
    @page_title ||= @board.pretty_title
    
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
  
  protected
  
  # Build prettier flash messages
  def format_flashes
    if flash[:notice].present? && flash[:notice].any?
      notices = flash[:notice].collect{ |notice| "<li>#{ notice }</li>" }.join
      flash[:notice] = "<ul>#{ notices }</ul>".html_safe
    else
      flash.delete :notice
    end
    
    if flash[:alert].present? && flash[:alert].any?
      alerts = ""
      
      flash[:alert].each do |sub_board, alert|
        item = "<li>#{ alert }</li>"
        
        if sub_board && sub_board.errors.respond_to?(:full_messages) && sub_board.errors.any?
          item += "<ul>"
          item += sub_board.errors.full_messages.map{ |error| "<li>#{ error }</li>" }.join
          item += "</ul>"
        end
        
        alerts += item
      end
      
      flash[:alert] = "<ul>#{ alerts }</ul>".html_safe
    else
      flash.delete :alert
    end
  end
end
