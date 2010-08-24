class EventsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  respond_to :js
  
  def report_comment
    @comment = Comment.find(params[:comment_id])
    @event = @comment.events.build( :user => current_zooniverse_user, 
                                      :title => "Comment reported by #{current_zooniverse_user.name}")
    
    @event.save
  end
  
  def report_user
    @user = User.find(params[:user_id])
    @event = @user.events.build(:user => current_zooniverse_user,
                                :title => "User reported by #{current_zooniverse_user.name}")
                         
                                
    if @event.save
      User.moderators.each { |moderator| Notifier.notify_reported_user(@user, moderator, current_zooniverse_user).deliver }
    end
  end
end
