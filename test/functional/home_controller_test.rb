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
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
    
    context "#cas_test not logged in" do
      setup do
        @request.session = nil
        get :cas_test
        puts @request.session.inspect
      end
      
      # FIX ME - this appears to be a known bug: http://github.com/thoughtbot/shoulda/issues/issue/117
      # should_redirect_to('cas server with gateway set to true') {'https://example.com/login?service=http%3A%2F%2Ftest.host%2F&gateway=true'}
      should_eventually "be redirected" do
        assert_redirected_to "The CAS login url"
      end
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
      should render_template :cas_test
    end
  end
end