require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  context "An Asset" do
    setup do
      @asset = Factory :asset
      @discussion = Factory :discussion
      @conversation = Factory :discussion
      @asset.discussions << @discussion
      @asset.conversation = @conversation
      @asset.save
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
  end
end
