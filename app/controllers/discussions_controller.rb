class DiscussionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :create]
  before_filter :require_privileged_user, :only => :toggle_featured
  respond_to :js, :only => [:user_owned, :toggle_featured, :list_for_asset, :list_for_boards, :list_for_collection]
  
  def show
    default_params :page => 1, :per_page => 10
    
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
    @comments = Comment.sort(:created_at.asc).where(:discussion_id => @discussion.id).paginate(:page => @page, :per_page => @per_page)
    @focus = @discussion.focus
    
    @comment = Comment.new
    if @discussion.focus_type == "Board"
      @title = @discussion.focus.title
      @bns_path = "/#{@title}"
    elsif @discussion.focus_type == "Collection"
      @title = @discussion.focus.name
      @bns_path = parent_url_for(@discussion)
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
    
    if @discussion.valid? && @comment.valid? && @focus
      @discussion.focus_id = @focus.id
      @discussion.focus_type = @focus.class.name
      @focus.discussion_ids << @discussion.id
      @focus.save
      @discussion.comments << @comment
      @discussion.save
      
      flash[:notice] = I18n.t 'controllers.discussions.flash_create'
      redirect_to discussion_url_for(@discussion)
    else
      render :action => :new
    end
  end
  
  def toggle_featured
    @discussion = Discussion.find(params[:id])
    @discussion.featured = !@discussion.featured
    @discussion.save
  end
  
  def list_for_object
    @discussions = Discussion.limit(10).sort(:created_at.desc).all(:focus_id => params[:id]) if params[:id]
    
    respond_with(@discussions) do |format|
      format.js { render :partial => "list_for_browser" }
    end
  end
  
  def list_for_collection
    @discussions = Discussion.limit(10).sort(:created_at.desc).all(:focus_id => params[:id]) if params[:id]
    
    respond_with(@discussions) do |format|
      format.js { render :partial => "list_for_browser" }
    end
  end
  
  def list_for_board
    @discussions = Discussion.limit(10).sort(:created_at.desc).all(:focus_id => params[:id]) if params[:id]
     respond_with(@discussions) do |format|
        format.js { render :partial => "list_for_browser" }
      end
  end
    
  protected
  
  def find_focus
    if params.has_key? :board_id
      @focus = Board.find_by_title(params[:board_id])
    else
      focus_id = params['discussion']['focus_id']
      focus_type = params['discussion']['focus_type']
      @focus = focus_type.constantize.find(focus_id) if focus_id
    end
  end
  
  def find_show_focus
    focus_key = params.keys.select{ |key| %w(object_id collection_id board_id).include? key }.first
    focus_id = params[focus_key]
    return unless focus_key and focus_id
    klass = focus_key.sub('_id', '').sub('object', 'asset').camelize.constantize
    klass = LiveCollection if focus_key == 'collection_id' && focus_id =~ /^CMZL/
    @focus = (klass == Board) ? klass.find_by_title(focus_id) : klass.find_by_zooniverse_id(focus_id)
  end
end
