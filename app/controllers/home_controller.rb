class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:cas_test]
  
  def index
    @recent_comments = Comment.most_recent 10
  end
  
  def cas_test
    @user = session[:cas_user]
  end
end
