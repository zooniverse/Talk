class CommentsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:create, :markitup_parser]
  respond_to :html, :only => :create
  respond_to :js, :only => [:vote_up, :report, :user_owned, :preview]
  
  def create
    @discussion = Discussion.find(params[:discussion_id])
    @discussion.comments.build(params[:comment])

    if @discussion.save
      flash[:notice] = t 'controllers.comments.flash_create'
      redirect_to discussion_url_for(@discussion)
    end
  end
  
  def vote_up
    @comment = Comment.find(params[:id])
    
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
      @event = @comment.events.build(:user => current_zooniverse_user, 
                                     :title => "#{ I18n.t('controllers.comments.reported') } #{ current_zooniverse_user.name }")

      @event.save
    end
  end
  
  def markitup_parser
    @comments = [Comment.new(:author => current_zooniverse_user, :body => params[:data] || "")]
    @comments.first.update_timestamps
    respond_with(@comments) do |format|
      format.js do
        render :update do |page|
          page['#comment-preview'].html(render :partial => "comments/markitup_parser")
        end
      end
    end
  end
  
  def preview
    @comment = Comment.find(params[:id])
    respond_with @comment
  end
  
  def more
    @page = params[:page] ? params[:page].to_i : 1
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    @discussion_id = params[:discussion_id]
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => @page, :per_page => @per_page)
  end
end
