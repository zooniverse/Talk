class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::Filter, :only => :cas_test
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index
  skip_before_filter :check_for_banned_user, :only => :index
  respond_to :js, :except => [:index, :cas_test]
  
  def index
    # Loading data for boards
    page_size = 6
    page = 0
    @help_board = Board.find_by_title("help")
    @help_list = @help_board.discussions.paginate(:per_page => page_size, :page => page)

    @chat_board = Board.find_by_title("chat")
    @chat_list = @chat_board.discussions.paginate(:per_page => page_size, :page => page)

    @science_board = Board.find_by_title("science")
    @science_list = @science_board.discussions.paginate(:per_page => page_size, :page => page)
  end
  
  def cas_test
    @user = session[:cas_user]
  end
  
  def trending_keywords
    @tags = Tag.rank_tags(:from => 0, :to => 8)
    respond_with(@tags) do |format|
      format.js { render "keywords" }
    end
  end
  
  %w(comments assets collections discussions).each do |kind|
    klass = kind.singularize.camelize.constantize
    
    define_method "recent_#{kind}".to_sym do
      respond_with(instance_variable_set("@#{kind}", klass.most_recent(5))) do |format|
        format.js { render kind }
      end
    end
    
    define_method "trending_#{kind}".to_sym do
      respond_with(instance_variable_set("@#{kind}", klass.trending(5))) do |format|
        format.js { render kind }
      end
    end
  end
end
