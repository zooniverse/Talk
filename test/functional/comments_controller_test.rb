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
    
    context "When requesting more #user_owned comments" do
      setup do
        20.times do |i|
          Comment.create(:author => @author, :discussion_id => @asset.conversation_id, :body => "blah")
        end
        
        post :user_owned, { :id => @author.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)

      should "display more comments" do
        assert_match /#more-comments.*.hide()/, @response.body, "more-comments link was not hidden"
        assert_equal 20, @response.body.scan(/comment-container/).length, "all comments weren't rendered"
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
