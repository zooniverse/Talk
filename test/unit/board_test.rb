require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  context "A Board" do
    setup do
      @help = Board.find_by_title("help")
      @science = Board.find_by_title("science")
      @chat = Board.find_by_title("chat")
      @test = Board.create :title => " A TITLE with Mixed CAse", :description => "Test"
      
      board_discussions_in @science, 2
      @discussion1 = Board.science.discussions[0]
      @discussion2 = Board.science.discussions[1]
    end
    
    should_have_keys :_type, :title, :description
    should_associate :discussions, :sub_boards
    should_include_modules 'MongoMapper::Document'
    
    should "have #by_title scope" do
      assert_equal @help, Board.by_title("help")
      assert_equal @science, Board.by_title("science")
      assert_equal @chat, Board.by_title("chat")
    end
    
    should "have title methods" do
      assert_equal @help, Board.help
      assert_equal @science, Board.science
      assert_equal @chat, Board.chat
    end
    
    should "#slugify_title" do
      assert_equal "a_title_with_mixed_case", @test.reload.title
    end
    
    should "format a #pretty_title" do
      assert_equal "A Title With Mixed Case", @test.reload.pretty_title
    end
    
    should "have path helpers" do
      assert_equal "/science", @science.path
      assert_equal "/science", @science.path(:page => 1, :per_page => 10)
      assert_equal "/science?page=2", @science.path(:page => 2, :per_page => 10)
      assert_equal "/science?per_page=8", @science.path(:page => 1, :per_page => 8)
      assert_equal "/science?page=3&per_page=8", @science.path(:page => 3, :per_page => 8)
      assert_equal "/science/discussions/new", @science.new_discussion_path
      assert_equal "/science/discussions/#{ @discussion1.zooniverse_id }", @science.discussion_path(@discussion1)
      assert_equal "/science/discussions/#{ @discussion1.zooniverse_id }?page=2&per_page=11", @science.discussion_path(@discussion1, :page => 2, :per_page => 11)
      assert_equal @science.discussion_path(@discussion1), @discussion1.path
      assert_equal @science.path, @discussion1.parent_path
      assert_equal "/science?page=2", @discussion1.parent_path(:page => 2, :per_page => 10)
    end
    
    context "listing #recent_discussions" do
      setup do
        board_discussions_in @help, 50
        @help.reload.discussions.each{ |d| d.set :updated_at => 1.hour.ago }
        
        @discussion1 = @help.discussions[0]
        @discussion1.set :updated_at => 1.minute.ago.utc
        
        @discussion2 = @help.discussions[1]
        @discussion2.set :updated_at => 2.minutes.ago.utc
        
        @discussion3 = @help.discussions[2]
        @discussion3.set :updated_at => 3.minutes.ago.utc
      end
      
      should "paginate correctly" do
        assert_equal [@discussion1, @discussion2, @discussion3], @help.recent_discussions(:per_page => 3)
        assert_equal [@discussion2], @help.recent_discussions(:per_page => 1, :page => 2)
      end
      
      should "filter by_user correctly" do
        assert_equal [@discussion1, @discussion2, @discussion3], @help.recent_discussions(:per_page => 3, :by_user => true)
        assert_equal [@discussion1, @discussion2, @discussion3], @help.recent_discussions(:per_page => 3, :for_user => @discussion1.started_by)
        assert_equal [@discussion1], @help.recent_discussions(:for_user => @discussion1.started_by, :by_user => true)
      end
    end
  end
end
