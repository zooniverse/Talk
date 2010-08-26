require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  context "Discussions controller" do
    setup do
      @controller = DiscussionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      build_focus_for(Factory :asset)
      @comment = @comment1
    end

    context "When requesting a Discussion" do
      setup do
        get :show, { :id => @discussion.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should_eventually "Display the discussion zooniverse_id" do
        assert_select 'h2.discussion-name', :text => @discussion.zooniverse_id
      end
    end
    
    context "When viewing a discussion with a comment written by self" do
      setup do
        standard_cas_login
        
        @comment1.author = @user
        @comment1.save
        
        get :show, { :id => @discussion.zooniverse_id }
      end

      should respond_with :success
      
      should "not see any links to vote up own comment" do
        assert_select "#comment-vote-#{@comment1.id}", 0
      end
      
      should "see any link to vote up other comment" do
        assert_select "#comment-vote-#{@comment2.id}", 1
      end
    end
  end
end
