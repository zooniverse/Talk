require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  context "Discussions controller" do
    setup do
      @controller = DiscussionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "When requesting a Board Discussion" do
      setup do
        board_discussions_in Board.science
        @discussion = Board.science.discussions.first
        get :show, { :id => @discussion.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "not show discussion-items" do
        assert_select ".discussion-items", false
      end
    end

    context "When requesting an Asset Discussion" do
      setup do
        @focus = Factory :asset
        build_focus_for @focus
        get :show, { :id => @discussion.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "Display the asset zooniverse_id" do
        assert_select ".discussion-title", :text => "#{@focus.zooniverse_id} discussion"
      end
      
      should "Display the asset image" do
        assert_select ".discussion-items img.focus-main-image"
      end
      
      should "Display the author of the discussion" do
        assert_select ".main h2", :text => "Started by #{@discussion.comments.first.author.name}"
      end
      
      should "Display the discussion tags" do
        assert_select ".subtext > a", @discussion.tags.length
      end
      
      should "not show the admin-tools" do
        assert_select "#admin-tools", false
      end
      
      should "list the comments" do
        assert_select ".comments-list > div.comment", @discussion.comments.length
        assert_select ".comments-list > div.comment:nth-child(1) .name", :text => @comment1.author.name
      end
    end
    
    context "When requesting a Collection Discussion" do
      setup do
        @asset = Factory :asset
        @focus = collection_for @asset
        build_focus_for @focus
        get :show, { :id => @discussion.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "Display the collection zooniverse_id" do
        assert_select ".discussion-title", :text => "#{@focus.zooniverse_id} discussion"
      end
      
      should "Display the collection images" do
        assert_select ".discussion-items", :html => /src="#{@asset.location}"/
        assert_select ".collection-thumbnail", 1
        assert_select ".discussion-items > a", :html => /src="#{@asset.thumbnail_location}"/
      end
    end
    
    context "When a privileged user requests a Discussion" do
      setup do
        @focus = Factory :asset
        build_focus_for @focus
        moderator_cas_login
        get :show, { :id => @discussion.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "show the admin-tools" do
        assert_select "#featured-link a", :text => "Make this a featured discussion"
      end
    end
    
    context "When viewing a discussion with a comment written by self" do
      setup do
        build_focus_for(Factory :asset)
        standard_cas_login(@comment1.author)
        
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
