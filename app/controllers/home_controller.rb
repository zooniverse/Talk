class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:cas_test]
  
  def index
    @recent_comments = Comment.most_recent 5
    @recent_assets = Asset.most_recently_commented_on 5
    @recent_collections = Collection.most_recent 5
    @recent_discussions = Discussion.most_recent 5
    
    @trending_assets = Asset.trending 5
    @trending_collections = Collection.trending 5
    @trending_discussions = Discussion.trending 5
    
    @trending_tags = Comment.trending_tags 10
    @trending_tags = Comment.rank_tags(@trending_tags,8)
    
  end
  
  def cas_test
    @user = session[:cas_user]
  end

  
end
