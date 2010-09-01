require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  context "A HomeController" do
    setup do
      @controller = HomeController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index not logged in" do
      setup do
        CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(true)
        @asset = Factory :asset
        build_focus_for(@asset)
        collection_for(@asset)
        board_discussions_in Board.help
        get :index
      end
      
      should respond_with :success
      should render_template :index
      
      should "Show trending" do
        assert_select "#trending-assets > .recent-asset", 3
        assert_select "#trending-collections > .recent-item", 1
        assert_select "#trending-discussions > .recent-item", 5
        assert_select "#keyword-cloud > li", 3
      end
      
      should "Show recent" do
        assert_select "#recent-assets > .recent-asset", 3
        assert_select "#recent-collections > .recent-item", 1
        assert_select "#recent-discussions > .recent-item", 5
        assert_select "#recent-comments > .recent-comment", 5
      end
      
      should "Show board discussions" do
        assert_select ".boards-list", 3
        assert_select ".boards-list ul > li.name", 6
      end
      
      should "Show about box" do
        assert_select "#about-box"
      end
    end
    
    context "#cas_test logged in" do
      setup do
        standard_cas_login
        get :cas_test
      end

      should respond_with :success
    end
  end
end
