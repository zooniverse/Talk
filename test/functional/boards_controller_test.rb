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
        assert_select '#board-heading h1', :text => @board.title
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
        assert_select '#board-heading h1', :text => @board.title
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
        assert_select '#board-heading h1', :text => @board.title
      end
    end
    
    context "#show" do
      setup do
        @board = Board.science
        @discussions = 12
        board_discussions_in @board, @discussions
        @discussion = @board.discussions.first
        @discussion.featured = true
        @discussion.save
        
        get 'science', { :page => 2, :per_page => 5 }
      end

      should "display meta information" do
        assert_select "#meta-for-discussions", :text => "#{@discussions} Discussions / #{@discussions * 2} Comments"
      end
      
      should "display discussions" do
        assert_select "#discussions-list > div", 5
      end
      
      should "display zooniverse ad" do
        assert_select "#zooniverse-extras"
      end
      
      should "display project link" do
        assert_select "#project-link"
      end
      
      should "display featured discussions" do
        assert_select "#help-wanted > .featured-item", 1
        assert_select "#help-wanted .name", :text => @discussion.subject
      end
      
      should "display pagination links" do
        assert_select "div.pagination", 1
        assert_select "div.pagination > a", 4
        assert_select "div.pagination", :text => /Previous 1 2 3 Next/
      end
    end
  end
end
