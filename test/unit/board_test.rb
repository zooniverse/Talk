require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  context "Board" do
    should "have class methods for boards" do
      %w(science chat help).each do |method|
        assert Board.respond_to?(method)
      end
    end
  end
end