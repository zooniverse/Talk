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
        standard_cas_login
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
    
    context "When viewing your own profile" do
      setup do
        standard_cas_login
        get :show, { :id => @user.id }
      end

      should respond_with :success
      should render_template :show
      
      should "Not show the report link" do
        assert_select "#report-user-link-#{@user.id}", 0
      end
      
      should "not show the moderation links" do
        assert_select "#moderation-links", 0
      end
    end
    
    context "When reporting a user as a standard user" do
      setup do
        standard_cas_login
        @viewed_user = Factory :user
        post :report, { :id => @viewed_user.id, :format => :js }
      end

      should respond_with :success
      should respond_with_content_type(:js)      
      
      should "add to the event list" do
        assert_equal @viewed_user.reload.events.size, 1
      end
    end
  end
end
