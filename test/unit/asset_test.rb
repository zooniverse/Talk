require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  context "An Asset" do
    setup do
      @asset = Factory :asset
    end

    should "include" do
      assert @asset.respond_to?(:location)
    end
  end  
end
