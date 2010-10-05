class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :require_privileged_user, :only => [:activate, :ban]
  
  respond_to :js, :except => [:show]
  respond_to :html, :only => [:show]

  def show
    @user = User.find(params[:id])
    @per_page = 10
    @comment_page = @discussion_page = 1
    
    @comments = @user.comments.paginate(:page => 1, :per_page => @per_page)
    @discussions = Discussion.where(:started_by_id => @user.id).sort(:popularity.desc).paginate(:page => 0, :per_page => @per_page)
  end
  
  def report
    @user = User.find(params[:id])
    @event = @user.events.build(:user => current_zooniverse_user,
                                :target_user => @user,
                                :title => "#{ @user.name } reported by #{current_zooniverse_user.name}")
                                
    if @event.save
      User.moderators.each { |moderator| Notifier.notify_reported_user(@user, moderator, current_zooniverse_user).deliver }
    end
  end
  
  def ban
    @user = User.find(params[:id])
    @user.ban(current_zooniverse_user)
    if @user.save
       Notifier.notify_banned_user(@user).deliver
        respond_with(@user) do |format|
            format.js {
              render :update do |page|
                page['#moderation-links'].html(render :partial => 'state')
              end
            }
        end
    end
  end
  
  def activate
    @user = User.find(params[:id])
    @user.redeem(current_zooniverse_user)
    if @user.save
      respond_with(@user) do |format|
          format.js {
            render :update do |page|
              page['#moderation-links'].html(render :partial => 'state')
            end
          }
      end
    end
  end
  
  def watch
    @user = User.find(params[:id])
    
    if @user.state == "active"
      @user.watch(current_zooniverse_user)
    else
      @user.unwatch(current_zooniverse_user)
    end
    
    if @user.save
      respond_with(@user) do |format|
          format.js {
            render :update do |page|
              page['#moderation-links'].html(render :partial => 'state')
            end
          }
      end
    end
  end
  
  def comments
    @user = User.find(params[:id])
    @comment_page = params[:page] ? params[:page].to_i : 1
    @comments = Comment.where(:author_id => @user.id).sort(:created_at.desc).paginate(:page => @comment_page, :per_page => 10)
  end
  
  def discussions
    @user = User.find(params[:id])
    @discussion_page = params[:page] ? params[:page].to_i : 1
    @discussions = Discussion.where(:started_by_id => @user.id).sort(:created_at.desc).paginate(:page => @discussion_page, :per_page => 10)
  end
  
end
