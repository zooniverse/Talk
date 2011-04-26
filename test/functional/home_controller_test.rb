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
        
        1.upto(5) do
          asset = Factory :asset
          build_focus_for asset
          asset_set_for asset
          conversation_for asset
        end
      end
      
      context "showing recent" do
        setup do
          get :index
        end
        
        should respond_with :success
        should render_template :index
        
        should "render recent" do
          assert_select ".mode_switch .current", :text => "Recent"
          assert_select ".mode_switch .page-loader", :text => "Trending"
          assert_select ".home #assets h2", :text => "RECENT OBJECTS"
          assert_select ".home #assets_page_1 > .asset", 4
          assert_select ".home #collections h2", :text => "RECENT COLLECTIONS"
          assert_select ".home #collections_page_1 > .collection", 4
          assert_select ".home #assets_page_1 .page-nav", :text => "Page 1 of 4"
          assert_select ".home #collections_page_1 .page-nav", :text => "Page 1 of 2"
          assert_select ".home #discussions-selector #since", true
          assert_select ".home #discussions-selector #by_user", false
          assert_select ".home #discussions h2", :text => "RECENT DISCUSSIONS"
          assert_select ".home #discussions_page_1 > .discussion", 8
          assert_select ".home #discussions_page_1 .page-nav", :text => /Page 1 of 3/
        end
      end
      
      context "showing trending" do
        setup do
          get :index, :showing => "trending"
        end
        
        should respond_with :success
        should render_template :index
        
        should "render trending" do
          assert_select ".mode_switch .current", :text => "Trending"
          assert_select ".mode_switch .page-loader", :text => "Recent"
          assert_select ".home #assets h2", :text => "TRENDING OBJECTS"
          assert_select ".home #assets_page_1 > .asset", 4
          assert_select ".home #collections h2", :text => "TRENDING COLLECTIONS"
          assert_select ".home #collections_page_1 > .collection", 4
          assert_select ".home #assets_page_1 .page-nav", :text => "1 to 4"
          assert_select ".home #collections_page_1 .page-nav", :text => "1 to 4"
          assert_select ".home #discussions-selector", true
          assert_select ".home #discussions h2", :text => "TRENDING DISCUSSIONS"
          assert_select ".home #discussions_page_1 > .discussion", 8
          assert_select ".home #discussions_page_1 .page-nav", :text => /Page 1 of 3/
        end
      end
    end
    
    context "#index logged in" do
      setup do
        standard_cas_login
        
        1.upto(5) do
          asset = Factory :asset
          build_focus_for asset
          asset_set_for asset
          conversation_for asset
        end
      end
      
      context "showing recent" do
        setup do
          get :index
        end
        
        should respond_with :success
        should render_template :index
        
        should "render recent" do
          assert_select ".mode_switch .current", :text => "Recent"
          assert_select ".mode_switch .page-loader", :text => "Trending"
          assert_select ".home #assets h2", :text => "RECENT OBJECTS"
          assert_select ".home #assets_page_1 > .asset", 4
          assert_select ".home #collections h2", :text => "RECENT COLLECTIONS"
          assert_select ".home #collections_page_1 > .collection", 4
          assert_select ".home #assets_page_1 .page-nav", :text => "Page 1 of 4"
          assert_select ".home #collections_page_1 .page-nav", :text => "Page 1 of 2"
          assert_select ".home #discussions-selector", true
          assert_select ".home #discussions-selector #since", true
          assert_select ".home #discussions-selector #by_user", true
          assert_select ".home #discussions h2", :text => "RECENT DISCUSSIONS"
          assert_select ".home #discussions_page_1 > .discussion", 8
          assert_select ".home #discussions_page_1 .page-nav", :text => /Page 1 of 3/
        end
      end
    end
  end
end
