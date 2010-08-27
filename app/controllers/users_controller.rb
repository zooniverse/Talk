class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  
  respond_to :js, :only => [:report, :activate, :ban]
  respond_to :html, :only => [:show]
  
  def show
    @user = User.find(params[:id])
    @discussions = Discussion.where(:started_by_id => @user.id).sort(['number_of_comments', -1]) 
  end
  
  def report
    @user = User.find(params[:id])
    @event = @user.events.build(:user => current_zooniverse_user,
                                :title => "User reported by #{current_zooniverse_user.name}")
                                
    if @event.save
      User.moderators.each { |moderator| Notifier.notify_reported_user(@user, moderator, current_zooniverse_user).deliver }
    end
  end
  
  
  def ban        
    @user = User.find(params[:id])
    @user.state = "banned"  
            
    if @user.save
       Notifier.notify_banned_user(@user)      
        respond_to do |format|
          format.js {
            render :update do |page|
              page['#moderation-links'].html(render :partial => 'shared/user_state')            
            end    
          }
       end      
     end   
  end
  
  def activate        
    @user = User.find(params[:id])
    @user.state = "active"  
            
    if @user.save
        respond_to do |format|
          format.js {
            render :update do |page|
              page['#moderation-links'].html(render :partial => 'shared/user_state')            
            end    
          }
       end      
     end   
  end
  
end
