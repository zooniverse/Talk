require 'test_helper'

class TagTest < ActiveSupport::TestCase
  context "A Tag" do
    setup do
      @asset = Factory :asset
      build_focus_for @asset
    end
    
    should "find tags #for_focus" do
      assert_equal ['tag2', 'tag4', 'tag1'], Tag.for_focus(@asset).collect{ |tag| tag.name }
    end
    
    should "find tags #for_discussion" do
      assert_equal ['tag2', 'tag4', 'tag1'], Tag.for_discussion(@discussion).collect{ |tag| tag.name }
    end

    should "find #trending" do
      assert_equal ['tag2', 'tag4', 'tag1'], Tag.trending
    end
    
    should "#rank_tags correctly" do
      ranked = Tag.rank_tags :from => 3, :to => 8
      
      assert_equal 3, ranked['tag1']
      assert_equal 6, ranked['tag4']
      assert_equal 8, ranked['tag2']
    end
  end
end
