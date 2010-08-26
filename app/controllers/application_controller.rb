class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_or_create_zooniverse_user
  
  def new_discussion_url_for(focus)
      case focus.class.to_s
      when "Asset"
        object_url = "/objects/#{focus.zooniverse_id}/discussions/new"
      when "Collection"
        collection_url = "/collections/#{focus.zooniverse_id}/discussions/new"
      when "LiveCollection"
        live_collection_url = "/live_collections/#{focus.zooniverse_id}/discussions/new"
      end
  end
  
  helper_method :new_discussion_url_for
  
  def discussion_url_for(discussion)
    focus = discussion.focus
    if discussion.focus_id.nil?
      discussion_path(discussion.zooniverse_id)
    elsif discussion.conversation?
      case focus.class.to_s
      when "Asset"
        object_path(focus.zooniverse_id)
      when "Collection"
        collection_path(focus.zooniverse_id)
      when "LiveCollection"
        live_collection_path(focus.zooniverse_id)
      end
    else
      case focus.class.to_s
      when "Asset"
        object_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
      when "Collection"
        collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
      when "LiveCollection"
        live_collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
      end
    end
  end
  
  helper_method :discussion_url_for
  
  def require_privileged_user
    unless current_zooniverse_user.moderator? || current_zooniverse_user.admin?
      flash[:notice] = t 'controllers.application.not_authorised'
      redirect_to root_url
    end
  end
  
  # This should work, but doesn't
  def require_user
    check_or_create_zooniverse_user
    CASClient::Frameworks::Rails::Filter
  end
  
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
