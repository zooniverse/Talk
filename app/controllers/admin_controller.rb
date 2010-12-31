class AdminController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :require_privileged_user
  respond_to :html, :js
  
  def index
    @more = params[:more]
    ivars = %w(reported_users reported_comments watched banned logged)
    cursors = [Event.pending_for_users, Event.pending_for_comments, User.watched, User.banned, Event.actioned.ignored]
    
    ivars.zip(cursors).each do |ivar, cursor|
      set_page(ivar, cursor)
    end
  end
  
  def ignore
    @event = Event.find(params[:id])
    @event.moderator = current_zooniverse_user
    @event.state = "ignored"
    @event.save
    
    set_page "reported_users", Event.pending_for_users
    set_page "reported_comments", Event.pending_for_comments
    set_page "logged", Event.actioned.ignored
  end
  
  def remove_comment
    @event = Event.find(params[:id])
    
    if @event.eventable.is_a?(Comment) && @event.eventable.destroy
      @event.moderator = current_zooniverse_user
      @event.state = "actioned"
      @event.save
    end
    
    set_page "reported_comments", Event.pending_for_comments
    set_page "logged", Event.actioned.ignored
  end
  
  def ban
    @event = Event.find(params[:id])
    @user = @event.target_user
    @user.ban(current_zooniverse_user)
    @user.save
    
    set_page "reported_users", Event.pending_for_users
    set_page "reported_comments", Event.pending_for_comments
    set_page "banned", User.banned
    set_page "logged", Event.actioned.ignored
  end
  
  def redeem
    @user = User.find(params[:id])
    @user.redeem(current_zooniverse_user)
    @user.save
    
    set_page "banned", User.banned
    set_page "logged", Event.actioned.ignored
  end
  
  def watch
    @user = User.find(params[:id])
    
    if @user.state == "active"
      @user.watch(current_zooniverse_user)
    else
      @user.unwatch(current_zooniverse_user)
    end
    
    @user.save
    set_page "watched", User.watched
    set_page "logged", Event.actioned.ignored
  end
  
  protected
  def set_page(ivar, cursor)
    page = "#{ ivar }_page"
    per_page = "#{ ivar }_per_page"
    ivar_page = instance_variable_set "@#{ page }", params[page.to_sym] ? params[page.to_sym].to_i : 1
    ivar_per_page = instance_variable_set "@#{ per_page }", params[per_page.to_sym] ? params[per_page.to_sym].to_i : 10
    instance_variable_set "@#{ ivar }", cursor.sort(:updated_at.desc).paginate(:page => ivar_page, :per_page => ivar_per_page)
  end
end
