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
        assert_select ".main h2", :text => "Started by #{@discussion.started_by.name}"
      end
      
      should "Display the discussion tags" do
        assert_select ".subtext > a", @discussion.keywords.length
      end
      
      should "not show the admin-tools" do
        assert_select "#admin-tools", false
      end
      
      should "list the comments" do
        assert_select ".comments-list > div.comment", @discussion.comments.length
        assert_select ".comments-list > div.comment:nth-child(1) .name", :text => @discussion.comments.first.author.name
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
    
    context "#create on asset" do
      setup do
        @asset = Factory :asset
        standard_cas_login
        options = {
          :discussion => {
            :subject => "Blah",
            :description => "blah",
            :focus_type => "Asset",
            :focus_id => @asset.id,
            :comments => {
              :body => "Hi",
              :author_id => @user.id
            }
          }
        }
        post :create, options
      end
      
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.discussions.flash_create'))

      should "redirect to asset discussion page" do
        assert_redirected_to object_discussion_path(@asset.zooniverse_id, assigns(:discussion).zooniverse_id)
      end
    end
    
    context "#create on board" do
      setup do
        @board = Board.science
        standard_cas_login
        options = {
          :board_id => "science",
          :discussion => {
            :subject => "Blah",
            :description => "blah",
            :comments => {
              :body => "Hi",
              :author_id => @user.id
            }
          }
        }
        post :create, options
      end
      
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.discussions.flash_create'))

      should "redirect to board discussion page" do
        assert_redirected_to discussion_path(assigns(:discussion).zooniverse_id)
      end
    end
    
    context "#toggle_featured" do
      setup do
        build_focus_for(Factory :asset)
        moderator_cas_login
        post :toggle_featured, { :id => @discussion.id, :format => :js }
      end
      
      should respond_with :success

      should "be featured" do
        assert @discussion.reload.featured
      end
      
      context "toggling again" do
        setup do
          post :toggle_featured, { :id => @discussion.id, :format => :js }
        end

        should "be unfeatured" do
          assert !@discussion.reload.featured
        end
      end
    end
    
    context "When requesting more #user_owned discussions" do
      setup do
        @author = Factory :user
        20.times do |i|
          Discussion.create(:started_by_id => @author.id, :subject => "blah")
        end
        
        post :user_owned, { :id => @author.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)

      should "display more discussions" do
        assert_match /#more-discussions.*.hide()/, @response.body, "more-discussions link was not hidden"
        assert_equal 20, @response.body.scan(/item-container/).length, "all discussions weren't rendered"
      end
    end
  end
end
