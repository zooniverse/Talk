class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::Filter, :only => :cas_test
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index
  
  def index
    @recent_comments = Comment.most_recent 5
    @recent_assets = Asset.most_recently_commented_on 5
    @recent_collections = Collection.most_recent 5
    @recent_discussions = Discussion.most_recent 5
    
    @trending_assets = Asset.trending 5
    @trending_collections = Collection.trending 5
    @trending_discussions = Discussion.trending 5
    
    @trending_tags = Comment.rank_tags :from => 0, :to => 8
    
    # Loading data for boards
    @help_board = Board.find_by_title("help")
    @help_list = @help_board.discussions

    @chat_board = Board.find_by_title("chat")
    @chat_list = @chat_board.discussions

    @science_board = Board.find_by_title("science")
    @science_list = @science_board.discussions
  end
  
  def cas_test
    @user = session[:cas_user]
  end  
end
