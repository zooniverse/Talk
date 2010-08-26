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
    
    context "When voting on a comment in a discussion" do
      setup do
        standard_cas_login
        post :vote_up, {:id => @comment.id, :format => :js}
      end

      should respond_with :success
      should respond_with_content_type(:js)      
      
      should "increase the numner of upvotes on the comment" do
        assert_equal 1, @comment.reload.upvotes.size
      end
    end
    
    context "When reporting a comment" do
      setup do
        standard_cas_login
        post :report, {:id => @comment.id, :format => :js}
      end

      should respond_with_content_type(:js)      

      should "increase the numner of events on the comment" do
        assert_equal 1, @comment.reload.events.size
      end
    end
  end
end
