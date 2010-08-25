class DiscussionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :create]
  def show
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
  end
  
  def new
    find_focus
    @board = params[:board_id]
    @discussion = Discussion.new
    @discussion.comments.build
  end
  
  def edit
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
  end
  
  def create
    find_focus
    comment_params = params[:discussion].delete :comments
    @comment = Comment.new(comment_params) if params.has_key? :discussion
    @discussion = Discussion.new(params[:discussion])
    
    if @discussion.valid? && @comment.valid?
      @discussion.comments << @comment
      
      if @focus
        @focus = @discussion.focus
        @focus.discussion_ids << @discussion.id
      else
        board = Board.find_by_title(params[:board_id])
        board.discussion_ids << @discussion.id
        board.save
      end
      
      redirect_to discussion_url_for(@discussion.focus, @discussion)
    else
      render discussion_url_for(@focus, @discussion)
    end
  end
  
  protected
  def find_focus
    focus_key = params.keys.select{ |key| ['object_id', 'collection_id', 'live_collection_id'].include? key }.first
    
    if focus_key
      @focus = focus_key.sub('object', 'asset').sub('_id', '').camelize.constantize.find_by_zooniverse_id(params[focus_key])
    end
  end
end
