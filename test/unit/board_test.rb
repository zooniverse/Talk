require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  context "A Board" do
    setup do
      @help = Board.find_by_title("help")
      @science = Board.find_by_title("science")
      @chat = Board.find_by_title("chat")
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
  end
end