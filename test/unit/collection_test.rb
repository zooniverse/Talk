require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  context "A Collection" do
    setup do
      @asset1 = Factory :asset
      collection_for @asset1
      build_focus_for @collection
      
      2.upto(5) do |i|
        asset = Factory :asset
        instance_variable_set "@asset#{i}", asset
        @collection.asset_ids << asset.id
        @collection.save
      end
    end
    
    should_have_keys :name, :description, :asset_ids, :user_id, :created_at, :updated_at
    should_associate :assets, :user
    should_include_modules :focus, :zooniverse_id, 'MongoMapper::Document'
    
    should "find #recent" do
      assert_same_elements [@collection, @collection2, @collection3], Collection.recent
    end
    
    should "find #recent_assets" do
      assert_equal [@asset5, @asset4, @asset3], @collection.recent_assets(3)
    end
    
    should "find collections #with_asset" do
      assert_equal [@collection], Collection.with_asset(@asset1)
    end
    
    context "#destroy" do
      setup do
        3.times{ conversation_for @collection }
        
        @conversation = @collection.conversation
        @discussions = @collection.discussions
        @document_hash = @collection.to_mongo
        
        @conversation.comments.first.body = "Edited"
        @conversation.comments.first.save
        
        @document_hash['conversation'] = @conversation.to_embedded_hash
        @document_hash['discussions'] = @collection.discussions.collect(&:to_embedded_hash)
        
        @collection.archive_and_destroy_as @collection.user
        @archive = Archive.first(:kind => "Collection", :original_id => @collection.id)
      end
      
      should "remove collection, discussions, and comments" do
        assert_raise(MongoMapper::DocumentNotFound) { @collection.reload }
        
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
        assert_equal "Collection", @archive.kind
        assert_equal @collection.id, @archive.original_id
        assert_equal @collection.zooniverse_id, @archive.zooniverse_id
        assert_equal @collection.user_id, @archive.user_id
        assert_equal @collection.user_id, @archive.destroying_user_id
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
