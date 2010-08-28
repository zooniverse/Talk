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
    
    context "when viewing #by_page" do
      setup do
        board_discussions_in @science
        @science.reload
        
        @page1 = Board.science.by_page :page => 1, :per_page => 3
        @page2 = Board.science.by_page :page => 2, :per_page => 3
        @page3 = Board.science.by_page :page => 3, :per_page => 3
      end
      
      should "know how many #total_pages there are" do
        assert_equal 3, @page1.total_pages
      end

      should "paginate discussions correctly" do
        discussion_ids = [@page1, @page2, @page3].collect do |page|
          page.current_page.collect{ |discussion| discussion.id }
        end
        
        assert_equal @science.discussion_ids.reverse, discussion_ids.flatten
      end
      
      should "find the #number_of_comments while paginated" do
        assert_equal 16, @page1.number_of_comments
      end
      
      should "find the #number_of_comments" do
        assert_equal 16, @science.number_of_comments
      end
    end
  end
end