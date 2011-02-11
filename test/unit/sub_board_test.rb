require 'test_helper'

class SubBoardTest < ActiveSupport::TestCase
  context "A SubBoard" do
    setup do
      @parent = Board.science
      @sub_board = SubBoard.new :pretty_title => "A science sub-board"
      @sub_board.board = @parent
      @sub_board.save
      
      board_discussions_in @sub_board
      @discussion = @sub_board.discussions.first
    end
    
    should_have_keys :_type, :title, :pretty_title
    should_associate :discussions, :board
    
    should "#slugify_title" do
      assert_equal "a_science_sub-board", @sub_board.reload.title
    end
    
    should "have path helpers" do
      assert_equal "/science/a_science_sub-board", @sub_board.path
      assert_equal "/science/a_science_sub-board", @sub_board.path(:page => 1, :per_page => 10)
      assert_equal "/science/a_science_sub-board?page=2", @sub_board.path(:page => 2, :per_page => 10)
      assert_equal "/science/a_science_sub-board?per_page=8", @sub_board.path(:page => 1, :per_page => 8)
      assert_equal "/science/a_science_sub-board?page=3&per_page=8", @sub_board.path(:page => 3, :per_page => 8)
      assert_equal "/science/a_science_sub-board/discussions/new", @sub_board.new_discussion_path
      assert_equal "/science/a_science_sub-board/discussions/#{ @discussion.zooniverse_id }", @sub_board.discussion_path(@discussion)
      assert_equal "/science/a_science_sub-board/discussions/#{ @discussion.zooniverse_id }?page=2&per_page=11", @sub_board.discussion_path(@discussion, :page => 2, :per_page => 11)
      assert_equal @sub_board.discussion_path(@discussion), @discussion.path
      assert_equal @sub_board.path, @discussion.parent_path
      assert_equal "/science/a_science_sub-board?page=2", @discussion.parent_path(:page => 2, :per_page => 10)
    end
    
    context "associated to a parent board" do
      setup do
        @sub_board_after = SubBoard.find(@sub_board.id)
        @sub_board_after.parent = @parent
        @sub_board_after.reload
      end
      
      should "properly associate to a parent board" do
        assert_equal @parent, @sub_board.board
        assert_equal @parent, @sub_board.parent
        assert_equal @parent, @sub_board_after.board
        assert_equal @parent, @sub_board_after.parent
      end
    end
    
  end
end
