require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  context "Board" do
    setup do
      %w(science chat help).each do |name|
        Board.create(:title => name, :description => "The #{name} board")
      end
    end

    should "have #science, #chat and #help boards" do
      assert_not_nil Board.find_by_title('science')
      assert_not_nil Board.find_by_title('chat')
      assert_not_nil Board.find_by_title('help')
      assert Board.find_by_title('board_that_doesnt_exist')
    end
  end
  
  context "Board" do
    should "have class methods for boards" do
      %w(science chat help).each do |method|
        assert Board.respond_to?(method)
      end
    end
  end
end