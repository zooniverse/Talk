require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  context "A Collection" do
    setup do 
      @user = Factory :user
      @collection= Collection.create({:name=>"collection",:description=>"jksdfsdngdsa", :user=>@user})
    end
  
    should "have keys" do
      [:name,:description, :tags, :asset_ids,:user_id].each do |key|
        assert @collection.respond_to?(key)
      end
    end
  
    should "create associations" do 
      assert @collection.associations.keys.include?("assets")
      assert @collection.associations.keys.include?("user")
    end
    
    should "include a working focus" do
      assert Collection.include?(Focus)      
    end
    
    should "include the zooniverse_id generator" do
      assert LiveCollection.include?(ZooniverseId)
    end
  end
  
end