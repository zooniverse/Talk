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
        @asset = Factory :asset
        build_focus_for @asset
      end

      should_eventually "find tag-matched assets" do
        assert_equal [@asset], @collection.assets
      end
    end
  end
end