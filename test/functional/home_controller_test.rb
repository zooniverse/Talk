require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  context "Home Controller" do
    setup do
      @controller = HomeController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "Index not logged in" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
  end
end
