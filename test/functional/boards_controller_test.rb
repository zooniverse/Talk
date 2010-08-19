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

      should_respond_with :success
      should_render_template :show
      
      should_eventually "show the science board" do
        assert_select 'h2.board-name', :text => @board.name
      end
    end
    
    context "When the chat board" do
      setup do
        @board = Factory :board, :title => "chat"
        get 'chat'
      end

      should_respond_with :success
      should_render_template :show
      
      should_eventually "show the chat board" do
        assert_select 'h2.board-name', :text => @board.name
      end
    end
    
    context "When the help board" do
      setup do
        @board = Factory :board, :title => "help"
        get 'help'
      end

      should_respond_with :success
      should_render_template :show
      
      should_eventually "show the help board" do
        assert_select 'h2.board-name', :text => @board.name
      end
    end
  end
end
