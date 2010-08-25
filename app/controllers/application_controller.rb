class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_or_create_zooniverse_user
  
  def discussion_url_for(focus, discussion)
    case focus.class.to_s
    when "Asset"
      object_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
    when "Collection"
      collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
    when "LiveCollection"
      live_collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
    end
  end
  
  helper_method :discussion_url_for
  
  helper_method :require_privileged_user
  
  def require_privileged_user
    unless current_zooniverse_user.moderator? || current_zooniverse_user.admin?
      flash[:notice] = t 'controllers.application.not_authorised'
      redirect_to root_url
    end
  end
  
  def require_user
    check_or_create_zooniverse_user
    CASClient::Frameworks::Rails::Filter
  end
  helper_method :require_user
  
  protected
  
  def zooniverse_user
    session[:cas_user]
  end
  
  def zooniverse_user_id
    session[:cas_extra_attributes]['id']
  end
  
  def current_zooniverse_user
    @current_zooniverse_user ||= (User.find_by_zooniverse_user_id(zooniverse_user_id) if zooniverse_user)
  end
  
  def check_or_create_zooniverse_user
    if zooniverse_user
      if user = User.find_by_zooniverse_user_id(zooniverse_user_id)
        user.update_attributes(:name => zooniverse_user)
      else
        User.create(:zooniverse_user_id => zooniverse_user_id, :name => zooniverse_user)
      end
    end
  end
  
  helper_method :current_zooniverse_user
end
