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
        @board = Board.science
        get 'science'
      end
      
      should respond_with :success
      should render_template :show
      
      should "show the science board" do
        assert_select '.lhc h2.title', :text => /#{ @board.title }/i
      end
    end
    
    context "When the chat board" do
      setup do
        @board = Board.chat
        get 'chat'
      end
      
      should respond_with :success
      should render_template :show
      
      should "show the chat board" do
        assert_select '.lhc h2.title', :text => /#{ @board.title }/i
      end
    end
    
    context "When the help board" do
      setup do
        @board = Board.help
        get 'help'
      end
      
      should respond_with :success
      should render_template :show
      
      should "show the help board" do
        assert_select '.lhc h2.title', :text => /#{ @board.title }/i
      end
    end
    
    context "#show" do
      setup do
        @board = Board.science
        board_discussions_in @board, 12
        @discussion = @board.discussions.first
        @discussion.featured = true
        @discussion.save
        
        get 'science', { :page => 2, :per_page => 5 }
      end
      
      should "display discussions" do
        assert_select "#discussions .discussion", 5
      end
      
      should "display pagination links" do
        assert_select ".page-nav .less", 1
        assert_select ".page-nav .pages", 1
        assert_select ".page-nav .more", 1
        
        assert_select ".page-nav .pages > a", 4
      end
    end
  end
end
