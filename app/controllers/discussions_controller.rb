class DiscussionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:show]
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :create, :edit, :update, :toggle_featured]
  before_filter :require_privileged_user, :only => :toggle_featured
  respond_to :js, :only => [:edit, :update, :toggle_featured, :browse]
  
  def show
    default_params :page => 1, :per_page => 10
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
    return not_found unless @discussion
    
    @comments = Comment.sort(:created_at.asc).where(:discussion_id => @discussion.id).paginate(:page => @page, :per_page => @per_page)
    @focus = @discussion.focus
    
    set_title_prefix
    @page_title += " | #{ @discussion.subject }"
    
    @comment = Comment.new
    if @discussion.focus_base_type == "Board"
      @title = @discussion.focus.pretty_title
    elsif @discussion.focus_base_type == "AssetSet"
      @title = @discussion.focus.name
    else
      @title = @discussion.focus.zooniverse_id
    end 
  end
  
  def new
    find_show_focus
    @board = params[:sub_board_id] || params[:board_id]
    @discussion = Discussion.new
    @discussion.comments.build
    
    set_title_prefix
    @page_title += " | New Discussion"
  end
  
  def edit
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
    return not_found unless @discussion
    return unless moderator_or_owner :can_modify?, @discussion
    
    respond_with @discussion
  end
  
  def update
    @discussion = Discussion.find(params[:id])
    return not_found unless @discussion
    return unless moderator_or_owner :can_modify?, @discussion
    
    if @discussion.update_attributes(params[:discussion])
      flash[:notice] = I18n.t 'controllers.discussions.flash_updated'
    else
      flash_model_errors_on(@discussion)
    end
    
    respond_with @discussion
  end
  
  def destroy
    @discussion = Discussion.find(params[:id])
    return not_found unless @discussion
    return unless moderator_or_owner :can_destroy?, @discussion
    
    if @discussion.archive_and_destroy_as(current_zooniverse_user)
      flash[:notice] = I18n.t 'controllers.discussions.flash_destroyed'
    else
      flash_model_errors_on(@discussion)
    end
    
    redirect_to @discussion.parent_path
  end
  
  def create
    find_focus
    comment_params = params[:discussion].delete :comments
    @comment = Comment.new(comment_params) if params.has_key? :discussion
    @comment.author = current_zooniverse_user if @comment
    @discussion = Discussion.new(params[:discussion])
    @discussion.started_by_id = current_zooniverse_user.id
    
    if @discussion.valid? && @comment.valid? && @focus
      @discussion.focus_id = @focus.id
      @discussion.focus_type = @focus.class.name
      
      @discussion.focus_base_type = if @focus.is_a?(KeywordSet)
        "AssetSet"
      elsif @focus.is_a?(SubBoard)
        "Board"
      else
        @focus.class.name
      end
      
      @focus.discussions << @discussion
      @focus.save
      @discussion.comments << @comment
      @discussion.save
      
      flash[:notice] = I18n.t 'controllers.discussions.flash_create'
      redirect_to @discussion.path
    else
      @comment.valid?
      flash_model_errors_on(@discussion, @comment)
      render :action => :new
    end
  end
  
  def toggle_featured
    @discussion = Discussion.find(params[:id])
    return not_found unless @discussion
    
    @discussion.featured = !@discussion.featured
    @discussion.save
  end
  
  def browse
    @discussions = Discussion.limit(10).sort(:created_at.desc).all(:focus_id => params[:id]) if params[:id]
    respond_with(@discussions) do |format|
      format.js { render :partial => "browse" }
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
    focus_key = params.keys.select{ |key| %w(object_id collection_id board_id group_id).include? key }.first
    focus_key = "sub_board_id" if params[:sub_board_id].present?
    focus_id = params[focus_key]
    return unless focus_key and focus_id
    klass = focus_key.sub('_id', '').sub('object', 'asset').camelize.constantize
    klass = KeywordSet if focus_key == 'collection_id' && focus_id =~ /^CMZL/
    @focus = ([Board, SubBoard].include? klass) ? klass.find_by_title(focus_id) : klass.find_by_zooniverse_id(focus_id)
  end
  
  def set_title_prefix
    @page_title = case @focus
    when Asset, Group
      @focus.zooniverse_id
    when AssetSet, KeywordSet
      @focus.name
    when SubBoard
      "#{ @focus.board.pretty_title } | #{ @focus.pretty_title }"
    when Board
      @focus.pretty_title
    end
  end
end
