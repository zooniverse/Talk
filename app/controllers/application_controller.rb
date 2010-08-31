class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_or_create_zooniverse_user
  before_filter :check_for_banned_user, :except => :cas_logout
  
  def get_featured_discussions
    @featured_list = Discussion.featured.all
  end
  
  helper_method :get_featured_discussions
  
  def new_discussion_url_for(focus)
      case focus.class.to_s
      when "Asset"
        object_url = "/objects/#{focus.zooniverse_id}/discussions/new"
      when "Board"
        board_url = "/boards/#{focus.title}/discussions/new"
      when "Collection"
        collection_url = "/collections/#{focus.zooniverse_id}/discussions/new"
      when "LiveCollection"
        live_collection_url = "/live_collections/#{focus.zooniverse_id}/discussions/new"
      end
  end
  
  helper_method :new_discussion_url_for
  
  def discussion_url_for(discussion)
    focus = discussion.focus
    if !focus.is_a?(Board) && discussion.conversation?
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
      when "Board"
        discussion_path(discussion.zooniverse_id)
      when "Collection"
        collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
      when "LiveCollection"
        live_collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
      end
    end
  end
  
  def parent_url_for(discussion)
    focus = discussion.focus
    case focus.class.to_s
    when "Asset"
      object_path(focus.zooniverse_id)
    when "Board"
      board_path(focus.title)
    when "Collection"
      collection_path(focus.zooniverse_id)
    when "LiveCollection"
      live_collection_path(focus.zooniverse_id)
    end
  end
  
  helper_method :parent_url_for
  
  helper_method :discussion_url_for
  
  def require_privileged_user
    unless current_zooniverse_user.moderator? || current_zooniverse_user.admin?
      flash[:notice] = t 'controllers.application.not_authorised'
      redirect_to root_url
    end
  end
  
  def cas_logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  
  protected
  
  def zooniverse_user
    session[:cas_user]
  end
  
  def zooniverse_user_id
    session[:cas_extra_attributes]['id']
  end
  
  def zooniverse_user_email
    session[:cas_extra_attributes]['email']
  end
  
  def current_zooniverse_user
    @current_zooniverse_user ||= (User.find_by_zooniverse_user_id(zooniverse_user_id) if zooniverse_user)
  end
  
  def check_or_create_zooniverse_user
    if zooniverse_user
      if user = User.find_by_zooniverse_user_id(zooniverse_user_id)
        user.update_attributes(:name => zooniverse_user, :email => zooniverse_user_email)
      else
        User.create(:zooniverse_user_id => zooniverse_user_id, :name => zooniverse_user, :email => zooniverse_user_email)
      end
    end
  end
  
  def check_for_banned_user
    if current_zooniverse_user
      if current_zooniverse_user.state == "banned"
        flash[:notice] = t 'controllers.home.banned'
        redirect_to root_url
      end
    end
  end
  
  helper_method :current_zooniverse_user
end
