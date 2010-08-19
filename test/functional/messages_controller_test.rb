require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  context "A MessagesController when NOT logged in" do
    setup do
      @controller = MessagesController.new
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
    
    context "#sent" do
      setup do
        get :sent
      end
      
      should_eventually "be redirected" do
        assert_redirected_to "The CAS login url"
      end
    end
    
    context "#show" do
      setup do
        @message = Factory :message
        get :show, { :id => @message.id }
      end
      
      should_eventually "be redirected" do
        assert_redirected_to "The CAS login url"
      end
    end
  end
  
  context "A MessagesController when logged in" do
    setup do
      @controller = MessagesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      standard_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
    
    context "#sent" do
      setup do
        get :sent
      end
      
      should respond_with :success
      should render_template :sent
    end
    
    context "#show" do
      setup do
        @message = Factory :message
        get :show, { :id => @message.id }
      end
      
      should respond_with :success
      should render_template :show
    end
  end
end
