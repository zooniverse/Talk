require 'test_helper'

class BoardsControllerTest < ActionController::TestCase
  context "Boards controller" do
    setup do
      @controller = BoardsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
          
    context "When the science board" do
      setup do
        @board = Factory :board, :title => "science"
        get 'science'
      end

      should respond_with :success
      should render_template :show
      
      should "show the science board" do
        assert_select '#board-heading h1', :text => @board.title
      end
    end
    
    context "When the chat board" do
      setup do
        @board = Factory :board, :title => "chat"
        get 'chat'
      end

      should respond_with :success
      should render_template :show
      
      should "show the chat board" do
        assert_select '#board-heading h1', :text => @board.title
      end
    end
    
    context "When the help board" do
      setup do
        @board = Factory :board, :title => "help"
        get 'help'
      end

      should respond_with :success
      should render_template :show
      
      should "show the help board" do
        assert_select '#board-heading h1', :text => @board.title
      end
    end
  end
end
