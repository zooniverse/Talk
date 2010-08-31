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

      should respond_with :success
      should render_template :show
      
      should "Display the live collection title" do
        assert_select 'h1.collection-title', :text => "#{@live_collection.name} by #{@live_collection.user.name}"
      end
    end
  end
end
