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
    default_params :page => 1, :per_page => 10
    @board = Board.by_title(title)
    @discussions = @board.discussions.paginate :page => @page, :per_page => @per_page
    
    render "show"
  end
end
