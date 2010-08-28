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
  
    should_have_keys :name, :description, :taggings, :asset_ids, :user_id, :created_at, :updated_at
    should_associate :assets, :user
    should_include_modules :focus, :zooniverse_id, :taggable, 'MongoMapper::Document'
    
    should "find #most_recent" do
      assert_same_elements [@collection, @collection2, @collection3], Collection.most_recent
    end
    
    should "find #most_recent_assets" do
      assert_equal [@asset5, @asset4, @asset3], @collection.most_recent_assets(3)
    end
    
    should "find collections #with_asset" do
      assert_equal [@collection], Collection.with_asset(@asset1)
    end
  end
end