ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def setup
    MongoMapper.database.collections.reject{ |c| c.name == 'system.indexes' }.each do |collection|
      collection.remove
    end
    
    Board.create(:title => "science", :description => "awesome")
    Board.create(:title => "help", :description => "awesome")
    Board.create(:title => "chat", :description => "awesome")
  end
  
  def standard_cas_login
    @user = Factory :user
    @request.session[:cas_user] = @user.name
    @request.session[:cas_extra_attributes] = {}
    @request.session[:cas_extra_attributes]['id'] = @user.zooniverse_user_id
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
  end
  
  def clear_cas
    @user = Factory :user
    @request.session[:cas_user] = {}
    @request.session[:cas_extra_attributes] = {}
  end
end
