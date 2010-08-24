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
    
    context "When viewing a user profile as a moderator" do
      setup do
        moderator_cas_login
        @viewed_user = Factory :user
        get :show, { :id => @viewed_user.id }
      end

      should respond_with :success
      should render_template :show
      
      should "Show the report link" do
        assert_select "#report-user-link-#{@viewed_user.id}"
      end
      
      should "Show the moderation links" do
        assert_select "#moderation-links"
      end
    end
    
    context "When viewing a user profile as a standard user" do
      setup do
        standard_cas_login
        @viewed_user = Factory :user
        get :show, { :id => @viewed_user.id }
      end

      should respond_with :success
      should render_template :show
      
      should "Show the report link" do
        assert_select "#report-user-link-#{@viewed_user.id}"
      end
      
      should "not show the moderation links" do
        assert_select "#moderation-links", 0
      end
    end
  end
end
