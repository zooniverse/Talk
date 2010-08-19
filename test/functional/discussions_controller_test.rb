require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  context "Discussions controller" do
    setup do
      @controller = DiscussionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "When requesting a Discussion" do
      setup do
        @discussion = Factory :discussion
        get :show, { :id => @discussion.zooniverse_id }
      end

      should_respond_with :success
      should_render_template :show
      
      should_eventually "Display the discussion zooniverse_id" do
        assert_select 'h2.discussion-name', :text => @discussion.zooniverse_id
      end
    end
  end
end
