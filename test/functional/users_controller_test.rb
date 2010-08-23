require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  context "Users Controller" do
    setup do
      @controller = UsersController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "When requesting a User" do
      setup do
        @user = Factory :user
        get :show, { :id => @user.id }
      end

      should respond_with :success
      should render_template :show
      
      should_eventually "Display the user display name" do
        assert_select 'h2.user-name', :text => @user.name
      end
    end
  end
end
