require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  
  context "AdminController when NOT logged in" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should_eventually "be redirected" do
        assert_redirected_to "The CAS login url"
      end
    end
  end
  
  context "AdminController when logged in and admin user" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      admin_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
  end
  
  context "AdminController when logged in and moderator user" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      moderator_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
  end
  
  context "AdminController when logged in and not admin user or moderator user" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      standard_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :redirect
      
      should_eventually "be redirected" do
        assert_redirected_to "the front page"
      end

    end
  end
  
end
