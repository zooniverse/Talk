class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::Filter, :only => :cas_test
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index
  skip_before_filter :check_for_banned_user, :only => :index
  respond_to :js, :except => [:index, :cas_test]
  
  def index
  end
  
  def cas_test
    @user = session[:cas_user]
  end
  
  %w(help science chat).each do |board|
    define_method "recent_#{board}".to_sym do
      @title = board
      @discussions = board_discussions(Board.find_by_title(board))
      
      respond_with(@discussions) do |format|
        format.js { render :partial => "discussions/discussions" }
      end
    end
  end
  
  def trending_keywords
    @tags = Tag.rank_tags :limit => 50, :from => 1, :to => 9
    respond_with(@tags) do |format|
      format.js { render "keywords" }
    end
  end
  
  %w(comments assets collections discussions).each do |kind|
    klass = kind.singularize.camelize.constantize
    
    define_method "recent_#{kind}".to_sym do
      respond_with(instance_variable_set("@#{kind}", klass.most_recent(5))) do |format|
        format.js { render :partial => "#{kind}/list_for_home" }
      end
    end
    
    define_method "trending_#{kind}".to_sym do
      respond_with(instance_variable_set("@#{kind}", klass.trending(5))) do |format|
        format.js { render :partial => "#{kind}/list_for_home" }
      end
    end
  end
  
  protected
  def board_discussions(board, limit = 5)
    Discussion.sort(:created_at.desc).limit(limit).all(:id.in => board.discussion_ids)
  end
end
