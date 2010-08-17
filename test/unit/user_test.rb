require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A user" do 
    setup do 
      @user = Factory :user
    end
    
    should "have keys" do
      [:zooniverse_user_id, :name, :collections,:live_collections,:comments,:messages, :sent_messages].each do |key|
        assert @user.respond_to?(key)
      end
    end
    
    should "have correct associations" do 
      assert @user.associations.keys.include?("comments")
      assert @user.associations.keys.include?("collections")
      assert @user.associations.keys.include?("live_collections")
      assert @user.associations.keys.include?("messages")
      assert @user.associations.keys.include?("sent_messages")
    end
  end
  
end