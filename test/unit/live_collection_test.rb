require 'test_helper'

class LiveCollectionTest < ActiveSupport::TestCase
  context "A LiveCollection" do
    setup do 
      @collection = Factory :live_collection
    end
  
    should "have keys" do
      [:name, :description, :tags, :user_id].each do |key|
        assert @collection.respond_to?(key)
      end
    end
  
    should "create associations" do 
      assert @collection.associations.keys.include?("user")
    end
    
    should "include a working focus" do
      assert LiveCollection.include?(Focus)
    end
    
    context "generating zooniverse_ids" do
      setup do
        @collections = []
        
        1.upto(35){ |i| @collections << Factory(:live_collection) }
      end

      should "include ZooniverseId" do
        assert LiveCollection.include?(ZooniverseId)
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
        @found1 = Factory :asset, :tags => [ "monkey", "awesome" ]
        @found2 = Factory :asset, :tags => [ "really", "awesome", "monkey" ]
        @not_found = Factory :asset, :tags => [ "big", "purple", "truck" ]
        @assets = @collection.assets
      end

      should "find tag-matched assets" do
        assert @assets.include?(@found1)
        assert @assets.include?(@found2)
        assert !@assets.include?(@not_found)
      end
    end
    
  end
end