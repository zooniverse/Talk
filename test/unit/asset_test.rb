require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  context "An Asset" do
    setup do
      @asset = Factory :asset
      build_focus_for @asset
    end

    should "have keys" do
      [:zooniverse_id, :location, :thumbnail_location, :coords, :size, :tags, :conversation, :conversation=].each do |key|
        assert @asset.respond_to?(key)
      end
    end
    
    should "create associations" do
      assert @asset.associations.keys.include?("discussions")
    end
    
    should "include a working Focus" do
      assert Asset.include?(Focus)
      [:conversation_id, :discussion_ids].each{ |key| assert @asset.respond_to?(key) }
      
      assert_equal @discussion, @asset.discussions.first
      assert_equal @conversation, @asset.conversation
      
      [@asset.discussions.first, @conversation].each do |discussion|
        assert_equal @asset.id, discussion.focus_id
        assert_equal @asset.class.name, discussion.focus_type
        assert_equal @asset, discussion.focus
      end
    end
    
    should "have aggregated #tags" do
      comment_tags = [@comment1, @comment2, @comment3].collect{ |c| c.tags }.flatten.uniq.sort
      assert_equal comment_tags, @asset.tags.sort
    end
    
    should "find #most_recently_mentioned" do
      assert_equal [@asset, @asset3, @asset2], Asset.most_recently_mentioned
    end
    
    should "find #most_recently_commented_on" do
      assert_equal [@asset, @asset3, @asset2], Asset.most_recently_commented_on
    end
    
    should "find #trending" do
      assert_equal [@asset2, @asset3, @asset], Asset.trending
    end
  end
end
