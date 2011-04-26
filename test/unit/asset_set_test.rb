require 'test_helper'

class AssetSetTest < ActiveSupport::TestCase
  context "A AssetSet" do
    setup do
      @asset1 = Factory :asset
      asset_set_for @asset1
      build_focus_for @asset_set
      
      2.upto(5) do |i|
        asset = Factory :asset
        instance_variable_set "@asset#{i}", asset
        @asset_set.asset_ids << asset.id
        @asset_set.save
      end
    end
    
    should_have_keys :name, :description, :asset_ids, :user_id, :created_at, :updated_at
    should_associate :assets, :user
    should_include_modules :focus, :zooniverse_id, 'MongoMapper::Document'
    
    should "find #recent" do
      assert_same_elements [@asset_set, @asset_set2, @asset_set3], AssetSet.recent
    end
    
    should "find #recent_assets" do
      assert_equal [@asset5, @asset4, @asset3], @asset_set.recent_assets(3)
    end
    
    should "find collections #with_asset" do
      assert_equal [@asset_set], AssetSet.with_asset(@asset1)
    end
    
    context "#destroy" do
      setup do
        3.times{ conversation_for @asset_set }
        
        @conversation = @asset_set.conversation
        @discussions = @asset_set.discussions
        @document_hash = @asset_set.to_mongo
        
        @conversation.comments.first.body = "Edited"
        @conversation.comments.first.save
        
        @document_hash['conversation'] = @conversation.to_embedded_hash
        @document_hash['discussions'] = @asset_set.discussions.collect(&:to_embedded_hash)
        
        @asset_set.archive_and_destroy_as @asset_set.user
        @archive = Archive.first(:kind => "AssetSet", :original_id => @asset_set.id)
      end
      
      should "remove collection, discussions, and comments" do
        assert_raise(MongoMapper::DocumentNotFound) { @asset_set.reload }
        
        assert_raise(MongoMapper::DocumentNotFound) { @conversation.reload }
        @conversation.comments.each do |comment|
          assert_raise(MongoMapper::DocumentNotFound) { comment.reload }
        end
        
        @discussions.each do |discussion|
          assert_raise(MongoMapper::DocumentNotFound) { discussion.reload }
          
          discussion.comments.each do |comment|
            assert_raise(MongoMapper::DocumentNotFound) { comment.reload }
          end
        end
      end
      
      should "Archive collection" do
        assert_equal "AssetSet", @archive.kind
        assert_equal @asset_set.id, @archive.original_id
        assert_equal @asset_set.zooniverse_id, @archive.zooniverse_id
        assert_equal @asset_set.user_id, @archive.user_id
        assert_equal @asset_set.user_id, @archive.destroying_user_id
        assert_equal @document_hash, @archive.original_document
      end
      
      should "not Archive discussions and comments separately" do
        assert_not Archive.exists?(:kind => "Comment")
        assert_not Archive.exists?(:kind => "Discussion")
        assert_equal 1, Archive.count
      end
    end
  end
end
