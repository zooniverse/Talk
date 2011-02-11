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
        assert_select '#boards .current', :text => /#{ @board.title }/i
        assert_select '#boards .arrange-link', 0
        assert_select '#boards #arrange-board', 0
        assert_select '#boards .edit-link', 0
        assert_select '#boards #edit-board', 0
        assert_select '.right .button span', :text => /Start a new discussion/
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
        @sub_board = sub_boards_in(@parent, 3).first
        @discussion = @sub_board.discussions.first
      end
      
      context "not logged in" do
        setup do
          get 'science', { :sub_board_id => 'sub_board_1' }
        end
        
        should respond_with :success
        should render_template :show
        
        should "show the sub boards" do
          assert_select '#boards .parent .children li', 3
          assert_select '#boards .current', :text => /#{ @sub_board.pretty_title }/
          assert_select "#boards ##{ @sub_board.id }", :html => /href=\"\/science\/sub_board_1\"/
        end
        
        should "display discussions" do
          assert_select "#discussions .discussion", 8
        end
      end
      
      context "logged in as a moderator" do
        setup do
          moderator_cas_login
          get 'science', { :sub_board_id => 'sub_board_1' }
        end
        
        should respond_with :success
        should render_template :show
        
        should "show the sub boards" do
          assert_select '#boards .parent .children li', 3
          assert_select '#boards .current', :text => /#{ @sub_board.pretty_title }/
          assert_select "#boards ##{ @sub_board.id }", :html => /href=\"\/science\/sub_board_1\"/
        end
        
        should "show the edit links" do
          assert_select '#boards .arrange-link', 1
          assert_select '#boards #arrange-board', 1
          assert_select '#boards .edit-link', 1
          assert_select '#boards #edit-board', 1
        end
        
        should "display discussions" do
          assert_select "#discussions .discussion", 8
        end
      end
    end
    
    context "#arrange ing SubBoards" do
      setup do
        @parent = Board.science
        @sub_boards = sub_boards_in(@parent, 5)
        @positioned = [@sub_boards[0], @sub_boards[2], @sub_boards[4], @sub_boards[1], @sub_boards[3]]
      end
      
      context "logged in as standard user" do
        setup do
          standard_cas_login
          post :arrange, { :format => :js, :id => @parent.id, :positions => @positioned.collect(&:id) }
        end
        
        should respond_with :found
        should respond_with_content_type :html
        should set_the_flash.to(I18n.t('controllers.application.not_authorised'))
        
        should "redirect to front page" do
          assert_redirected_to root_path
        end
        
        should "not change positions" do
          assert_equal [0, 0, 0, 0, 0], @positioned.map(&:reload).collect(&:position)
        end
      end
      
      context "logged in as a moderator" do
        setup do
          moderator_cas_login
          post :arrange, { :format => :js, :id => @parent.id, :positions => @positioned.collect(&:id) }
        end
        
        should respond_with :success
        should respond_with_content_type :js
        
        should "set the flash to \"Your changes have been saved\"" do
          assert_match /.*notice.*Your changes have been saved.*/, response.body
        end
        
        should "change positions" do
          assert_equal @positioned.map(&:reload), @parent.sub_boards.sort(:position.asc).all
        end
      end
    end
    
    context "#update ing SubBoards" do
      setup do
        @parent = Board.science
        @sub_boards = sub_boards_in(@parent, 4)
        
        @options = {
          :format => :js,
          :id => @parent.id,
          :sub_boards => {
            @sub_boards[0].id.to_s => {
              :title => "Renamed"
            },
            @sub_boards[1].id.to_s => {
              :title => "Sub Board 3"
            },
            @sub_boards[3].id.to_s => {
              :destroy => true
            },
            :new_1297378872605 => {
              :create => true,
              :title => "ShouldCreate"
            },
            :new_1297378879421 => {
              :create => true,
              :title => "DontCreate",
              :destroy => "true"
            }
          }
        }
      end
      
      context "logged in as a moderator" do
        setup do
          moderator_cas_login
          post :update, @options
        end
        
        should respond_with :success
        should respond_with_content_type :js
        
        should "set the flash correctly" do
          assert_match /.*notice.*Renamed was updated.*/, response.body
          assert_match /.*notice.*Sub Board 4 was removed.*/, response.body
          assert_match /.*notice.*Shouldcreate was created.*/, response.body
          assert_match /.*alert.*Sub Board 2's title could not be changed to \\\"Sub Board 3\\\".*Title has already been taken.*/, response.body
        end
        
        should "update boards correctly" do
          assert_equal "Renamed", @sub_boards[0].reload.pretty_title
          assert_equal "Sub Board 2", @sub_boards[1].reload.pretty_title
          assert_raise(MongoMapper::DocumentNotFound) { @sub_boards[3].reload }
          assert SubBoard.exists?(:title => "shouldcreate")
          assert_not SubBoard.exists?(:title => "dontcreate")
        end
      end
      
      context "logged in as standard user" do
        setup do
          standard_cas_login
          post :update, @options
        end
        
        should respond_with :found
        should respond_with_content_type :html
        should set_the_flash.to(I18n.t('controllers.application.not_authorised'))
        
        should "redirect to front page" do
          assert_redirected_to root_path
        end
        
        should "not update boards" do
          assert_equal "Sub Board 1", @sub_boards[0].reload.pretty_title
          assert_equal "Sub Board 2", @sub_boards[1].reload.pretty_title
          assert_nothing_raised { @sub_boards[3].reload }
          assert_not SubBoard.exists?(:title => "shouldcreate")
          assert_not SubBoard.exists?(:title => "dontcreate")
        end
      end
    end
  end
end
