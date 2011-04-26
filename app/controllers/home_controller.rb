class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:index, :browse]
  skip_before_filter :check_for_banned_user, :only => :index
  respond_to :html
  respond_to :js
  
  def index
    set_options
    set_documents @showing
    @featured = Discussion.featured.limit(5).all
    @tags = Tag.rank_tags :from => 1, :to => 9, :limit => 50
  end
  
  def more
    set_options
    set_documents @showing
  end
  
  def browse
  end
  
  def status
  end
  
  protected
  def set_options
    default_params :showing => "recent",
                   :kinds => "assets asset_sets discussions",
                   :by_user => false,
                   :since => Time.now.utc.beginning_of_day,
                   :switching => false,
                   :selecting => false
    
    @kinds = @kinds.split
    if params[:since].blank? && current_zooniverse_user && current_zooniverse_user.last_login_at
      @since = current_zooniverse_user.last_login_at
    elsif params[:since].present?
      @since = Time.parse(params[:since]).utc
    end
    
    @since = Time.now.utc.beginning_of_day if @since.blank?
    
    @kinds.each do |kind|
      page = params["#{ kind }_page"] ? params["#{ kind }_page"].to_i : 1
      instance_variable_set "@#{ kind }_options", { :page => page, :per_page => 4 }
    end
    
    if @discussions_options
      @discussions_options.merge!({
        :per_page => 8,
        :since => @since,
        :for_user => current_zooniverse_user,
        :read_list => session[:read_list] || [],
        :by_user => @by_user
      })
      
      @since_options = {
        "In the last day" => 1.day.ago.utc,
        "In the last week" => 1.week.ago.utc,
        "Choose..." => 'selector'
      }
      
      if current_zooniverse_user
        @since_options = { "Since my last login" => current_zooniverse_user.last_login_at }.merge(@since_options)
        @by_user_options = { "Anybody" => false, "Me" => true }
      end
    end
  end
  
  def set_documents(method)
    @kinds.each do |kind|
      options = instance_variable_get "@#{ kind }_options"
      instance_variable_set "@#{ kind }", kind.classify.constantize.send(method.to_sym, options)
    end
  end
end
