ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
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
