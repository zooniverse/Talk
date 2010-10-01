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
      
      should "Display the user display name" do
        assert_select '.profile .info h1', :text => @user.name
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
    
    context "When requesting more user #discussions" do
      setup do
        @author = Factory :user
        20.times do |i|
          Discussion.create(:started_by_id => @author.id, :subject => "blah")
        end
        
        post :discussions, { :id => @author.id, :page => 2, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)

      should "display more discussions" do
        assert_match /.more-results.*.remove()/, @response.body, "more discussions link was not removed"
        assert_equal 10, @response.body.scan(/item-container/).length, "all discussions weren't rendered"
        assert_not_match /if\(true\)/, @response.body, "more discussions link was shown again (it shouldn't be)"
      end
    end
    
    context "When requesting more user #comments" do
      setup do
        @asset = Factory :asset
        build_focus_for(@asset)
        @author = Factory :user
        
        20.times do |i|
          Comment.create(:author => @author, :discussion_id => @asset.conversation_id, :body => "blah")
        end
        
        post :comments, { :id => @author.id, :page => 2, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)

      should "display more comments" do
        assert_match /.more-results.*.remove()/, @response.body, "more comments link was not hidden"
        assert_equal 10, @response.body.scan(/comment-container/).length, "all comments weren't rendered"
        assert_not_match /if\(true\)/, @response.body, "more comments link was shown again (it shouldn't be)"
      end
    end
  end
end
