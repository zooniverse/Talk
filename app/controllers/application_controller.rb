class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_or_create_zooniverse_user
  
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
