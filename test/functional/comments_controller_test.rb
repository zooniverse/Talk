require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "Comments Controller" do
    setup do
      @controller = CommentsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "When voting on a comment in a discussion" do
      setup do
        standard_cas_login
        @author = Factory :user
        @discussion = Factory :discussion
        @comment = Factory :comment, :discussion => @discussion, :author => @author
        
        post :vote_up, {:id => @comment.id, :format => :js}
      end

      should respond_with :success
      
      should "increase the numner of upvotes on the comment" do
        assert_equal 1, @comment.reload.upvotes.size
      end
    end
  end
end
