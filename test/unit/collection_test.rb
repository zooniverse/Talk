require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  context "A Collection" do
    setup do 
      @collection = Factory :collection
      build_focus_for @collection
      
      1.upto(5) do |i|
        asset = Factory(:asset)
        instance_variable_set "@asset#{i}", asset
        @collection.asset_ids << asset.id
        @collection.save
      end
    end
    
    should_have_keys :name, :description, :asset_ids, :user_id, :created_at, :updated_at
    should_associate :assets, :user
    should_include_modules :focus, :zooniverse_id, 'MongoMapper::Document'
    
    should "find #most_recent" do
      assert_same_elements [@collection, @collection2, @collection3], Collection.most_recent
    end
    
    should "find #most_recent_assets" do
      assert_equal [@asset5, @asset4, @asset3], @collection.most_recent_assets(3)
    end
    
    should "find collections #with_asset" do
      assert_equal [@collection], Collection.with_asset(@asset1)
    end
    
    context "#destroy" do
      setup do
        3.times{ conversation_for @collection }
        @collection.destroy
        @archive = ArchivedCollection.find_by_zooniverse_id(@collection.zooniverse_id)
      end
      
      should "remove collection" do
        assert_raise(MongoMapper::DocumentNotFound) { @collection.reload }
      end
      
      should "create ArchivedCollection" do
        assert_equal @collection.user_id, @archive.user_id
        assert_equal @collection.to_mongo, @archive.collection_archive
        assert_equal @collection.conversation.to_embedded_hash, @archive.conversation_archive
        assert_same_elements @collection.discussions.collect(&:to_embedded_hash), @archive.discussions_archive
      end
    end
  end
end
