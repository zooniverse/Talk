require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  context "A Board" do
    setup do
      @help = Board.find_by_title("help")
      @science = Board.find_by_title("science")
      @chat = Board.find_by_title("chat")
      
      board_discussions_in @science, 2
      @discussion1 = Board.science.discussions[0]
      @discussion2 = Board.science.discussions[1]
    end
    
    should_have_keys :title, :description, :discussion_ids
    should_associate :discussions
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
    
    context "when removing a discussion" do
      setup do
        Board.science.pull_discussion @discussion1
      end
      
      should "correctly #pull_discussion from discussion_ids" do
        assert_equal [@discussion2.id], Board.science.discussion_ids
      end
    end
  end
end
