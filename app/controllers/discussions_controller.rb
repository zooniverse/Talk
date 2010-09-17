class DiscussionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :create]
  before_filter :require_privileged_user, :only => :toggle_featured
  respond_to :js, :only => [:user_owned, :toggle_featured]
  
  def show
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
    @comment = Comment.new
    if @discussion.focus_type == "Board"
      @title = @discussion.focus.title
      @bns_path = "/#{@title}"
    else
      @title = @discussion.focus.zooniverse_id
      @bns_path = parent_url_for(@discussion)
    end 
  end
  
  def new
    find_show_focus
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
    @discussion.started_by_id = current_zooniverse_user.id
    
    if @discussion.valid? && @comment.valid?
      if @focus
        @focus = @discussion.focus
        @focus.discussion_ids << @discussion.id
        @focus.save
        
        @discussion.comments << @comment
      else
        board = Board.find_by_title(params[:board_id])
        board.discussion_ids << @discussion.id
        @discussion.focus_type = "Board"
        @discussion.focus_id = board.id
        board.save
        
        @discussion.comments << @comment
      end
      
      flash[:notice] = I18n.t 'controllers.discussions.flash_create'
      redirect_to discussion_url_for(@discussion)
    else
      render discussion_url_for(@discussion)
    end
  end
  
  def toggle_featured
    @discussion = Discussion.find(params[:id])
    @discussion.featured = !@discussion.featured
    @discussion.save
  end
  
  def user_owned
    @user = User.find(params[:id])
    @discussions = Discussion.where(:started_by_id => @user.id).sort(:popularity.desc)
    respond_with(@discussions) do |format|
        format.js { 
          render :update do |page|              
            page['.popular-discussions .inner'].html(render :partial => "shared/list_of_discussions_main", :locals => { :discussions_list => @discussions, :id_of_box => "trending-discussions"})
            page['#more-discussions'].hide()
          end
        }
    end
  end
  
  protected
  
  def find_focus
    focus_id = params['discussion']['focus_id']
    focus_type = params['discussion']['focus_type']

    if focus_id
      @focus = focus_type.constantize.find(focus_id)
    end
  end
  
  #FIX ME - (sorry)
  def find_show_focus
    focus_key = params.keys.select{ |key| ['object_id', 'collection_id', 'live_collection_id'].include? key }.first
    
    if focus_key
      @focus = focus_key.sub('object', 'asset').sub('_id', '').camelize.constantize.find_by_zooniverse_id(params[focus_key])
    end
  end
end
