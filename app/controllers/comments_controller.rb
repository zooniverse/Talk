class CommentsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:create, :update, :destroy, :markitup_parser, :vote_up, :report]
  respond_to :html, :only => :create
  respond_to :js, :only => [:edit, :update, :destroy, :vote_up, :report, :preview]
  
  def create
    default_params :page => 1
    @discussion = Discussion.find(params[:discussion_id])
    comment = Comment.new(params[:comment])
    comment.author = current_zooniverse_user
    @discussion.comments << comment
    
    if @discussion.save
      flash[:notice] = t 'controllers.comments.flash_create'
      redirect_to @discussion.path(:page => @page)
    end
  end
  
  def edit
    @comment = Comment.find(params[:id])
    return not_found unless @comment
    return unless moderator_or_owner :can_modify?, @comment
    
    @short_display = @comment.discussion.conversation?
  end
  
  def update
    @comment = Comment.find(params[:id])
    return not_found unless @comment
    return unless moderator_or_owner :can_modify?, @comment
    
    @short_display = @comment.discussion.conversation?
    
    if @comment.update_attributes(params[:comment], :revising_user => current_zooniverse_user)
      flash[:notice] = I18n.t 'controllers.comments.flash_updated'
    else
      flash_model_errors_on(@comment)
    end
    
    @focus = @comment.focus
    respond_with @comment
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    return not_found unless @comment
    return unless moderator_or_owner :can_destroy?, @comment
    
    @short_display = @comment.discussion.conversation?
    
    if @comment.archive_and_destroy_as(current_zooniverse_user)
      flash[:notice] = I18n.t 'controllers.comments.flash_destroyed'
    end
    
    @focus = @comment.focus
    respond_with @comment
  end
  
  def vote_up
    @comment = Comment.find(params[:id])
    return not_found unless @comment
    
    if current_zooniverse_user.nil?
      flash[:alert] = I18n.t('controllers.comments.not_logged_in')
      render :action_denied
    elsif @comment.author == current_zooniverse_user
      flash[:alert] = I18n.t('controllers.comments.own_comment')
      render :action_denied
    else
      @comment.cast_vote_by(current_zooniverse_user)
    end
  end
  
  def report
    if current_zooniverse_user.nil?
      flash[:alert] = I18n.t('controllers.comments.not_logged_in')
      render :action_denied
    else
      @comment = Comment.find(params[:id])
      return not_found unless @comment
      
      @event = @comment.events.build(:user => current_zooniverse_user,
                                     :target_user => @comment.author,
                                     :title => "#{ @comment.author.name }#{ I18n.t('controllers.comments.reported') } #{ current_zooniverse_user.name }")
      
      @event.save
    end
  end
  
  def markitup_parser
    @comment = Comment.new(:body => params[:body] || "")
    @comment.author = current_zooniverse_user
    @comment.update_timestamps
    
    respond_with(@comment) do |format|
      format.js do
        render :update do |page|
          page[".comment-preview.in-use"].html(render :partial => "comments/markitup_parser")
        end
      end
    end
  end
  
  def preview
    @comment = Comment.find(params[:id])
    return not_found unless @comment
    
    respond_with @comment
  end
  
  def more
    default_params :page => 1, :per_page => 10
    @discussion_id = params[:discussion_id]
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => @page, :per_page => @per_page)
  end
end
