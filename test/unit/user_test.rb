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
  
  context "When banning a user that is alread banned" do
    setup do
      @user = Factory :user, :state => 'banned'
    end

    should "fail" do
      assert !@user.ban
    end
  end
  
  context "When banning a user" do
    setup do
      @user = Factory :user
      @user.ban
    end

    should have_sent_email
  end
  
  
  context "When redeeming a user" do
    setup do
      @user = Factory :user, :state => 'banned'
      @user.redeem
    end

    should have_sent_email
  end
end