require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "Comments Controller" do
    setup do
      @controller = CommentsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @author = Factory :user
      @asset = Factory :asset
      build_focus_for(@asset)
      @comment = @comment1
    end
    
    context "#create logged in" do
      setup do
        standard_cas_login
        @discussion = @asset.conversation
        options = {
          :discussion_id => @discussion.id,
          :comment => {
            :body => "Hey!"
          }
        }
        
        post :create, options
      end
      
      should set_the_flash.to(I18n.t('controllers.comments.flash_create'))
      
      should "be redirected to conversation" do
        assert_redirected_to object_path(@asset.zooniverse_id)
      end
    end
    
    context "#update not logged in" do
      setup do
        options = {
          :format => :js,
          :id => @comment.id,
          :comment => {
            :body => "nope"
          }
        }
        
        post :update, options
      end
      
      should respond_with_content_type :html
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.application.not_yours'))
      
      should "not update attributes" do
        before = @comment.to_mongo
        assert_equal before, @comment.reload.to_mongo
      end
    end
    
    context "#update logged in as owner" do
      setup do
        standard_cas_login(@comment.author)
        
        options = {
          :format => :js,
          :id => @comment.id,
          :comment => {
            :body => "updated!"
          }
        }
        
        post :update, options
      end
      
      should respond_with_content_type :js
      should respond_with :success
      
      should "update attributes" do
        @comment.reload
        assert_equal "updated!", @comment.body
        assert @comment.tags.empty?
        assert @comment.mentions.empty?
      end
      
      should "#create_revision and increment edit_count" do
        assert Revision.first(:original_id => @comment.id)
        assert_equal 1, @comment.reload.edit_count
      end
    end
    
    context "#update logged in as moderator" do
      setup do
        moderator_cas_login
        
        options = {
          :format => :js,
          :id => @comment.id,
          :comment => {
            :body => "updated!"
          }
        }
        
        post :update, options
      end
      
      should respond_with_content_type :js
      should respond_with :success
      
      should "update attributes" do
        @comment.reload
        assert_equal "updated!", @comment.body
        assert @comment.tags.empty?
        assert @comment.mentions.empty?
      end
      
      should "#create_revision and increment edit_count" do
        assert Revision.first(:original_id => @comment.id)
        assert_equal 1, @comment.reload.edit_count
      end
    end
    
    context "#update logged in as somebody else" do
      setup do
        standard_cas_login
        
        options = {
          :format => :js,
          :id => @comment.id,
          :comment => {
            :body => "nope"
          }
        }
        
        post :update, options
      end
      
      should respond_with_content_type :html
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.application.not_yours'))
      
      should "not update attributes" do
        before = @comment.to_mongo
        assert_equal before, @comment.reload.to_mongo
      end
    end
    
    context "#destroy not logged in" do
      setup do
        post :destroy, { :id => @comment.id, :format => :js }
      end
      
      should respond_with_content_type :html
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.application.not_yours'))
      
      should "not destroy comment" do
        assert_nothing_raised{ @comment.reload }
      end
    end
    
    context "#destroy logged in as owner" do
      setup do
        standard_cas_login(@comment.author)
        post :destroy, { :id => @comment.id, :format => :js }
      end
      
      should respond_with_content_type :js
      should respond_with :success
      
      should "destroy and archive comment" do
        assert_raise(MongoMapper::DocumentNotFound) { @comment.reload }
        archive = Archive.first(:kind => "Comment", :original_id => @comment.id)
        
        assert archive
        assert_equal @user.id, archive.destroying_user_id
      end
    end
    
    context "#destroy logged in as moderator" do
      setup do
        moderator_cas_login
        post :destroy, { :id => @comment.id, :format => :js }
      end
      
      should respond_with_content_type :js
      should respond_with :success
      
      should "destroy and archive comment" do
        assert_raise(MongoMapper::DocumentNotFound) { @comment.reload }
        archive = Archive.first(:kind => "Comment", :original_id => @comment.id)
        
        assert archive
        assert_equal @user.id, archive.destroying_user_id
      end
    end
    
    context "#destroy logged in as somebody else" do
      setup do
        standard_cas_login
        post :destroy, { :id => @comment.id, :format => :js }
      end
      
      should respond_with_content_type :html
      should respond_with :found
      should set_the_flash.to(I18n.t('controllers.application.not_yours'))
      
      should "not destroy comment" do
        assert_nothing_raised{ @comment.reload }
      end
    end
    
    context "When voting on a comment in a discussion logged in" do
      setup do
        standard_cas_login
        post :vote_up, { :id => @comment.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "increase the numner of upvotes on the comment" do
        assert_equal 1, @comment.reload.upvotes.size
      end
    end
    
    context "When voting on a comment in a discussion not logged in" do
      setup do
        post :vote_up, { :id => @comment.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      should render_template :action_denied
      should set_the_flash.to(I18n.t('controllers.comments.not_logged_in'))
      
      should "not increase the numner of upvotes on the comment" do
        assert_equal 0, @comment.reload.upvotes.size
      end
    end
    
    context "When reporting a comment logged in" do
      setup do
        standard_cas_login
        post :report, { :id => @comment.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      should render_template :report
      
      should "increase the numner of events on the comment" do
        assert_equal 1, @comment.reload.events.size
      end
    end
    
    context "When reporting a comment not logged in" do
      setup do
        post :report, { :id => @comment.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      should render_template :action_denied
      should set_the_flash.to(I18n.t('controllers.comments.not_logged_in'))
      
      should "not increase the numner of events on the comment" do
        assert_equal 0, @comment.reload.events.size
      end
    end
    
    context "When parsing markdown" do
      setup do
        standard_cas_login
        @data = "![logo](http://www.zooniverse.org/images/header1.gif \"zooniverse logo\")"
        @html = '<p><img src=\"http://www.zooniverse.org/images/header1.gif\" title=\"zooniverse logo\" alt=\"logo\" /></p>'
        
        post :markitup_parser, { :data => @data, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "produce the correct html" do
        assert response.body.include?(@html)
      end
    end
  end
end
