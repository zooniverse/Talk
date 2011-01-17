require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  context "An Asset" do
    setup do
      @asset = Factory :asset
      build_focus_for @asset
    end
    
    should_associate :discussions
    should_include_modules :focus, 'MongoMapper::Document'
    should_have_keys :zooniverse_id, :location, :thumbnail_location, :coords, :size, :tags,
                     :conversation_id, :discussion_ids, :created_at, :updated_at
    
    should "include a working Focus" do
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
      comment_tags = [@comment1, @comment2, @comment3].collect{ |c| c.tags }.flatten.uniq
      assert_same_elements comment_tags, @asset.tags
    end
    
    should "find #recently_mentioned" do
      assert_same_elements [@asset, @asset2, @asset3], Asset.recently_mentioned(3)
    end
    
    should "find #recently_commented_on" do
      assert_same_elements [@asset, @asset2, @asset3], Asset.recent(3)
    end
    
    should "find #trending" do
      assert_same_elements [@asset, @asset2, @asset3], Asset.trending
    end
    
    should "find assets #with_keywords" do
      assert_same_elements [@asset, @asset2, @asset3], Asset.with_keywords("tag1", "tag2", "tag4")
    end
    
    should "find #collections containing this asset" do
      collection = Factory :collection
      collection.assets << @asset
      collection.save
      assert_equal [collection], @asset.collections
    end
    
    should "find comments that #mentions this asset" do
      assert_same_elements [@comment1, @comment2, @comment3], @asset.mentions
    end
  end
end
