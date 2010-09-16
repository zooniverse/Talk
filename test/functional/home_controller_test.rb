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
      
      context "showing #trending_assets" do
        setup do
          get :trending_assets, { :format => :js }
        end
        
        should respond_with :success
        should render_template :assets
      end
      
      context "showing #recent_assets" do
        setup do
          get :recent_assets, { :format => :js }
        end

        should respond_with :success
        should render_template :assets
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
