class HomeController < ApplicationController 
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:cas_test]
  
  def index
    
  end
  
  def cas_test
    @user = session[:cas_user]
  end
end
