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
        assert_select ".comment-container", false
      end
    end
    
    context "#index with malformed keywords" do
      setup do
        get :index, { :search => "keywords:", :for => "objects" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "not list results" do
        assert_select ".comments-list", 1
        assert_select ".comment-container", false
      end
    end
    
    context "#index with keywords for objects" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        get :index, { :search => "keywords: #tag1", :for => "objects" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list assets" do
        [@asset, @asset2, @asset3].each do |asset|
          assert_select "a[href='/objects/#{asset.zooniverse_id}']", 2
        end
      end
    end
    
    context "#index with multiple keywords for objects" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        comment = Comment.new :body => "it's #awesome"
        comment.author = @comment1.author
        @asset.conversation.comments << comment
        
        get :index, { :search => "keywords: #tag1, awesome", :for => "objects" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list assets" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}']", 2
        assert_select "a[href='/objects/#{@asset2.zooniverse_id}']", false
        assert_select "a[href='/objects/#{@asset3.zooniverse_id}']", false
      end
    end
    
    context "#index with keywords for collections" do
      setup do
        @asset = Factory :asset
        @collection = collection_for @asset
        @collection2 = collection_for @asset
        
        build_focus_for @collection
        build_focus_for @collection2
        
        get :index, { :search => "keywords: #tag1", :for => "collections" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list collections" do
        assert_select "a[href='/collections/#{@collection.zooniverse_id}']", 1
        assert_select "a[href='/collections/#{@collection2.zooniverse_id}']", 1
      end
    end
    
    context "#index with multiple keywords for collections" do
      setup do
        @asset = Factory :asset
        @collection = collection_for @asset
        @collection2 = collection_for @asset
        build_focus_for @collection
        build_focus_for @collection2
        comment = Comment.new :body => "it's #awesome"
        comment.author = @comment1.author
        @collection.conversation.comments << comment
        
        get :index, { :search => "keywords: #tag1, awesome", :for => "collections" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list collections" do
        assert_select "a[href='/collections/#{@collection.zooniverse_id}']", 1
        assert_select "a[href='/collections/#{@collection2.zooniverse_id}']", false
      end
    end
    
    context "#index with keywords for comments" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        get :index, { :search => "keywords: #tag1", :for => "comments" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list comments" do
        assert_select ".item", 3
      end
    end
    
    context "#index with multiple keywords for comments" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        @comment1.body += " #awesome"
        @comment1.save
        
        get :index, { :search => "keywords: #tag1, #tag2, awesome", :for => "comments" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list comments" do
        assert_select ".item", 1
      end
    end
    
    context "#index with text search for comments" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        get :index, { :search => @asset.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list comments" do
        assert_select ".item", 3
      end
      
      should "link to discussions" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}/discussions/#{@discussion.zooniverse_id}']"
      end
    end
    
    context "#index with multiple text search terms for comments" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        @comment1.body += " awesomeness"
        @comment1.save
        get :index, { :search => "#{ @asset.zooniverse_id} awesomeness" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list comments" do
        assert_select ".item", 1
      end
      
      should "link to discussions" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}/discussions/#{@discussion.zooniverse_id}']"
      end
    end
    
    context "#index with text search for objects" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        get :index, { :search => @asset.zooniverse_id, :for => "objects" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list assets" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}']", 2
      end
    end
    
    context "#index with multiple text search terms for objects" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        
        @comment1.body += " awesomeness"
        @comment1.save
        other = @asset2.discussions.first.comments.first
        other.body += " awesomeness"
        other.save
        
        get :index, { :search => "#{ @asset.zooniverse_id } awesomeness", :for => "objects" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list assets" do
        assert_select "a[href='/objects/#{@asset.zooniverse_id}']", 2
      end
    end
    
    context "#index with text search for collections" do
      setup do
        @asset = Factory :asset
        @collection = collection_for @asset
        build_focus_for @collection
        
        get :index, { :search => @collection.zooniverse_id, :for => "collections" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list collections" do
        assert_select "a[href='/collections/#{@collection.zooniverse_id}']", 1
      end
    end
    
    context "#index with multiple text search terms for collections" do
      setup do
        @asset = Factory :asset
        @collection = collection_for @asset
        build_focus_for @collection
        
        @comment1.body += " awesomeness"
        @comment1.save
        other = @collection2.discussions.first.comments.first
        other.body += " awesomeness"
        other.save
        
        get :index, { :search => "#{ @collection.zooniverse_id } awesomeness", :for => "collections" }
      end
      
      should respond_with :success
      should render_template :index
      
      should "list collections" do
        assert_select "a[href='/collections/#{@collection.zooniverse_id}']", 1
      end
    end
  end
end
