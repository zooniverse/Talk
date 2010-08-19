class CommentsController < ApplicationController
  def create
    @discussion = Discussion.find(params[:discussion_id])
    @discussion.comments.build(params[:comment])
    
    if @discussion.save
      flash[:notice] = t 'controllers.comments.flash_create'      
      redirect_to discussion_url_for(@discussion.focus, @discussion)
    end
  end
end
