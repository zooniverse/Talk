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
      
      should "Display the asset image" do
        assert_select ".discussion-items img.focus-main-image"
      end
      
      should "Display the author of the discussion" do
        assert_select ".discussion-header .started_by", :text => /Started by.*#{@discussion.started_by.name}/m
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
            
      should "Display the collection images" do
        assert_select ".discussion-items", :html => /src="#{@asset.thumbnail_location}"/
        assert_select ".collection-thumbnail", 1
        assert_select ".container .discussed.col > a", :html => /src="#{ @asset.thumbnail_location }"/
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
      
      should "#create discussion" do
        assert Discussion.find(@asset.reload.discussions.first.id)
      end
      
      should "#create comment" do
        comment = Comment.first(:body => "Hi")
        comment.author = @user
        discussion = Discussion.find(@asset.reload.discussions.first.id)
        
        assert comment
        assert_equal comment, discussion.comments.first
      end
      
      should "have denormalized counts" do
        discussion = Discussion.find(@asset.reload.discussions.first.id)
        assert_equal 1, discussion.number_of_users
        assert_equal 1, discussion.number_of_comments
        assert_equal 2, discussion.popularity
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
            :comments => {
              :body => "Hi"
            }
          }
        }
        post :create, options
      end
      
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.discussions.flash_create'))
      
      should "redirect to board discussion page" do
        assert_redirected_to science_board_discussion_path(nil, assigns(:discussion).zooniverse_id)
      end
    end
    
    context "#update" do
      setup do
        build_focus_for Factory(:asset)
      end
      
      context "when not logged in" do
        setup do
          options = {
            :format => :js,
            :id => @discussion.id,
            :discussion => {
              :subject => "nope"
            }
          }
          
          post :update, options
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.application.not_yours'))
        
        should "not update attributes" do
          before = @discussion.to_mongo
          assert_equal before, @discussion.reload.to_mongo
        end
      end
      
      context "when logged in as owner" do
        setup do
          standard_cas_login(@discussion.started_by)
          
          options = {
            :format => :js,
            :id => @discussion.id,
            :discussion => {
              :subject => "updated!"
            }
          }
          
          post :update, options
        end
        
        should respond_with_content_type :js
        should respond_with :success
        
        should "update attributes" do
          @discussion.reload
          assert_equal "updated!", @discussion.subject
        end
      end
      
      context "when logged in as moderator" do
        setup do
          moderator_cas_login
          
          options = {
            :format => :js,
            :id => @discussion.id,
            :discussion => {
              :subject => "updated!"
            }
          }
          
          post :update, options
        end
        
        should respond_with_content_type :js
        should respond_with :success
        
        should "update attributes" do
          @discussion.reload
          assert_equal "updated!", @discussion.subject
        end
      end
      
      context "when logged in as somebody else" do
        setup do
          standard_cas_login
          
          options = {
            :format => :js,
            :id => @discussion.id,
            :discussion => {
              :subject => "nope"
            }
          }
          
          post :update, options
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.application.not_yours'))
        
        should "not update attributes" do
          before = @discussion.to_mongo
          assert_equal before, @discussion.reload.to_mongo
        end
      end
    end
    
    context "#destroy" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        board_discussions_in Board.science, 2
        @board_discussion = Board.science.discussions.first
      end
      
      context "when not logged in" do
        setup do
          post :destroy, { :id => @discussion.id }
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.application.not_yours'))
        
        should "not destroy discussion" do
          assert_nothing_raised{ @discussion.reload }
        end
        
        should "be redirected to the front page" do
          assert_redirected_to root_path
        end
      end
      
      context "when logged in as owner and comments still exist" do
        setup do
          standard_cas_login(@discussion.started_by)
          @comments = @discussion.comments
          post :destroy, { :id => @discussion.id }
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.application.not_yours'))
        
        should "not destroy discussion" do
          assert_nothing_raised{ @discussion.reload }
        end
        
        should "not destroy comments" do
          @comments.each do |comment|
            assert_nothing_raised{ comment.reload }
          end
        end
        
        should "be redirected to the front page" do
          assert_redirected_to root_path
        end
      end
      
      context "when logged in as owner and no comments exist" do
        setup do
          standard_cas_login(@board_discussion.started_by)
          @board_discussion.comments.map(&:destroy)
          @board_discussion.reload
          post :destroy, { :id => @board_discussion.id }
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.discussions.flash_destroyed'))
        
        should "archive and destroy discussion" do
          assert_raise(MongoMapper::DocumentNotFound) { @board_discussion.reload }
          archive = Archive.first(:kind => "Discussion", :original_id => @board_discussion.id)
          
          assert archive
          assert_equal @user.id, archive.destroying_user_id
        end
        
        should "be redirected to focus" do
          assert_redirected_to science_board_path
        end
        
        should "be removed from board" do
          assert_does_not_contain Board.science.discussions, @board_discussion
        end
      end
      
      context "when logged in as moderator" do
        setup do
          moderator_cas_login
        end
        
        context "when comments still exist" do
          setup do
            @comments = @discussion.comments
            post :destroy, { :id => @discussion.id }
          end
          
          should respond_with_content_type :html
          should respond_with :found
          should set_the_flash.to(I18n.t('controllers.discussions.flash_destroyed'))
          
          should "archive and destroy discussion" do
            assert_raise(MongoMapper::DocumentNotFound) { @discussion.reload }
            archive = Archive.first(:kind => "Discussion", :original_id => @discussion.id)
            
            assert archive
            assert_equal @user.id, archive.destroying_user_id
          end
          
          should "destroy comments" do
            @comments.each do |comment|
              assert_raise(MongoMapper::DocumentNotFound) { comment.reload }
            end
          end
          
          should "be redirected to focus" do
            assert_redirected_to object_path(@asset.zooniverse_id)
          end
        end
        
        context "when no comments exist" do
          setup do
            @board_discussion.comments.map(&:destroy)
            @board_discussion.reload
            post :destroy, { :id => @board_discussion.id }
          end
          
          should respond_with_content_type :html
          should respond_with :found
          should set_the_flash.to(I18n.t('controllers.discussions.flash_destroyed'))
          
          should "archive and destroy discussion" do
            assert_raise(MongoMapper::DocumentNotFound) { @board_discussion.reload }
            archive = Archive.first(:kind => "Discussion", :original_id => @board_discussion.id)
            
            assert archive
            assert_equal @user.id, archive.destroying_user_id
          end
          
          should "be redirected to focus" do
            assert_redirected_to science_board_path
          end
          
          should "be removed from board" do
            assert_does_not_contain Board.science.discussions, @board_discussion
          end
        end
      end
      
      context "when logged in as somebody else and comments still exist" do
        setup do
          standard_cas_login
          @comments = @discussion.comments
          post :destroy, { :id => @discussion.id }
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.application.not_yours'))
        
        should "not destroy discussion" do
          assert_nothing_raised{ @discussion.reload }
        end
        
        should "not destroy comments" do
          @comments.each do |comment|
            assert_nothing_raised{ comment.reload }
          end
        end
        
        should "be redirected to the front page" do
          assert_redirected_to root_path
        end
      end
      
      context "when logged in as somebody else and no comments exist" do
        setup do
          standard_cas_login
          @board_discussion.comments.map(&:destroy)
          @board_discussion.reload
          post :destroy, { :id => @board_discussion.id }
        end
        
        should respond_with_content_type :html
        should respond_with :found
        should set_the_flash.to(I18n.t('controllers.application.not_yours'))
        
        should "not destroy discussion" do
          assert_nothing_raised{ @board_discussion.reload }
        end
        
        should "be redirected to the front page" do
          assert_redirected_to root_path
        end
        
        should "not remove the discussion from the board" do
          assert_contains Board.science.discussions, @board_discussion
        end
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
  end
end
