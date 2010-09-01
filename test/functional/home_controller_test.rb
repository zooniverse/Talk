require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  context "Home Controller actions when not logged in" do
    setup do
      @controller = HomeController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index not logged in" do
      setup do
        CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(true)
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
  end
  
  context "Home Controller actions when logged in as standard user" do
    setup do
      @controller = HomeController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      standard_cas_login
    end

    context "#cas_test logged in" do
      setup do
        standard_cas_login
        get :cas_test
      end

      should respond_with :success
    end
  end
end