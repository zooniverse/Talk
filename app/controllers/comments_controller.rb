class CommentsController < ApplicationController
  respond_to :html, :only => :create
  respond_to :js, :only => [:vote_up, :report]
  
  def create
    @discussion = Discussion.find(params[:discussion_id])
    @discussion.comments.build(params[:comment])
    
    if @discussion.save
      flash[:notice] = t 'controllers.comments.flash_create'      
      redirect_to discussion_url_for(@discussion.focus, @discussion)
    end
  end
  
  def vote_up
    @comment = Comment.find(params[:id])
    
    if @comment.author == current_zooniverse_user
      render :vote_up_denied
    else
      @comment.cast_vote_by(current_zooniverse_user)
    end
  end
  
  def report
    @comment = Comment.find(params[:id])
    @event = @comment.events.build(:user => current_zooniverse_user, 
                                   :title => "Comment reported by #{current_zooniverse_user.name}")
    
    @event.save
  end
end
