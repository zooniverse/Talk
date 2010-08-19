require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase 
  context "Collections controller" do
    setup do
      @controller = CollectionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "When requesting a Collection" do
      setup do
        @collection = Factory :collection
        get :show, { :id => @collection.zooniverse_id }
      end

      should_respond_with :success
      should_render_template :show
      
      should_eventually "Display the collection zooniverse_id" do
        assert_select 'h2.collection-name', :text => @collection.zooniverse_id
      end
    end
  end
end
