require 'test_helper'

class LiveCollectionsControllerTest < ActionController::TestCase
  context "Live Collections Controller" do
    setup do
      @controller = LiveCollectionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "When requesting a Live Collection" do
      setup do
        @live_collection = Factory :live_collection
        get :show, { :id => @live_collection.zooniverse_id }
      end

      should_respond_with :success
      should_render_template :show
      
      should_eventually "Display the live collection zooniverse_id" do
        assert_select 'h2.collection-name', :text => @live_collection.zooniverse_id
      end
      
      should_eventually "Display the live collection owner name" do
        assert_select 'h2.collection-owner-name', :text => @live_collection.user.name
      end 
    end
  end
end
