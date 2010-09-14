require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  context "A SearchController" do
    setup do
      @controller = SearchController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "#index without query" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
      
      should "not list results" do
        assert_select ".comments-list", false
      end
    end
    
    context "#index with malformed keywords" do
      setup do
        get :index, { :search => "keywords: " }
      end
      
      should respond_with :success
      should render_template :index
      
      should "not list results" do
        assert_select ".comments-list", false
      end
    end
    
    context "#index with keywords" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        get :index, { :search => "keywords:tag1" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list comments" do
        assert_select ".comments-list > div.short-comment", 3
      end
      
      should "list discussions" do
        [@asset, @asset2, @asset3].each do |asset|
          d_id = asset.discussions.first.zooniverse_id
          assert_select "a[href='/objects/#{asset.zooniverse_id}/discussions/#{d_id}']"
        end
      end
      
      should "list assets" do
        [@asset, @asset2, @asset3].each do |asset|
          assert_select "a[href='/objects/#{asset.zooniverse_id}']", 2
        end
      end
    end
    
    context "#index with text search" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        get :index, { :search => @asset.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list comments" do
        assert_select ".comments-list > div.short-comment", 3
      end
      
      should "list discussions" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}/discussions/#{@discussion.zooniverse_id}']"
      end
      
      should "list assets" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}']", 2
      end
    end
  end
end
