class CommentsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :create
  respond_to :html, :only => :create
  respond_to :js, :only => [:vote_up, :report, :user_owned]
  
  def create
    if current_zooniverse_user.nil?
      redirect_to CASClient::Frameworks::Rails::Filter.login_url(self)
    else
      @discussion = Discussion.find(params[:discussion_id])
      @discussion.comments.build(params[:comment])

      if @discussion.save
        flash[:notice] = t 'controllers.comments.flash_create'
        redirect_to discussion_url_for(@discussion)
      end
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
                                     :title => "Comment reported by #{current_zooniverse_user.name}")

      @event.save
    end
  end
  
  def markitup_parser
    render :text => BlueCloth::new(params[:data]).to_html
  end
  
  def user_owned
    @user = User.find(params[:id])
    @user_comments = @user.comments
    respond_with(@user_comments) do |format|
        format.js { 
          render :update do |page|              
            page['.user-comments .inner'].html(render :partial => "shared/list_of_comments", :locals => { :comments_list => @user_comments, :id_of_box => "recent-comments" })
            page['#more-comments'].hide()
          end
        }
    end
  end
end
