require 'test_helper'

class BoardsControllerTest < ActionController::TestCase
  context "Boards controller" do
    setup do
      @controller = BoardsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      # Not sure if this has always been happening, but this test suite fails to gateway correctly when ran individually
      # ie rake test:functionals TEST=test/functionals/boards_controller_test.rb
      # but works fine when ran with all tests and in development/production.
      # 
      # Uncomment these lines if you're running this test by itself:
      # CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(false)
      # CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(false)
    end
    
    context "When the science board" do
      setup do
        @board = Board.science
        get 'science'
      end
      
      should respond_with :success
      should render_template :show
      
      should "show the science board" do
        assert_select '#boards .current', :text => /#{ @board.title }/i
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
        assert_select '#boards .current', :text => /#{ @board.title }/i
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
        assert_select '#boards .current', :text => /#{ @board.title }/i
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
      
      should respond_with :success
      should render_template :show
      
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
    
    context "#show with a SubBoard" do
      setup do
        @parent = Board.science
        @sub_board = SubBoard.new :title => "A science sub-board"
        @sub_board.board = @parent
        @sub_board.save
        
        board_discussions_in @sub_board
        @discussion = @sub_board.discussions.first
        
        get 'science', { :sub_board_id => 'a_science_sub-board' }
      end
      
      should respond_with :success
      should render_template :show
      
      should "show the sub board" do
        assert_select '#boards .current', :text => /#{ @sub_board.pretty_title }/i
      end
      
      should "display discussions" do
        assert_select "#discussions .discussion", 8
      end
    end
  end
end
