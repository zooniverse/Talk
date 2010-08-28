require 'test_helper'

class LiveCollectionTest < ActiveSupport::TestCase
  context "A LiveCollection" do
    setup do 
      @collection = Factory :live_collection
    end
  
    should_have_keys :zooniverse_id, :name, :description, :tags, :user_id
    should_associate :user
    should_include_modules :focus, :zooniverse_id, 'MongoMapper::Document'
    
    context "generating zooniverse_ids" do
      setup do
        @collections = []
        
        1.upto(35){ |i| @collections << Factory(:live_collection) }
      end
      
      should "increment 9 to a" do
        assert_equal "CMZS00000a", @collections[8].zooniverse_id
      end
      
      should "increment z to 1" do
        assert_equal "CMZS000010", @collections[34].zooniverse_id
      end
    end
    
    context "Finding #assets" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
      end

      should "find tag-matched assets" do
        assert_same_elements [@asset, @asset2, @asset3], @collection.assets
      end
    end
    
    should "find #most_recent" do
      assert_equal [@collection], LiveCollection.most_recent
    end
  end
end