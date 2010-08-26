class BoardsController < ApplicationController
  def show
    show_by_title(params[:board_id])
  end
  
  %w(help science chat).each do |title|
    define_method(title.to_sym) do
      show_by_title title
    end
  end
  
  def show_by_title(title)
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    @page = params[:page] ? params[:page].to_i : 1
    @board = Board.by_title(title, :page => @page, :per_page => @per_page)
    @discussions_list = @board.current_page
    
    render "show"
  end
end
