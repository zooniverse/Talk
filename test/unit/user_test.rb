require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A user" do 
    setup do 
      @user = Factory :user
      @admin = Factory :user, :admin => true
      @moderator = Factory :user, :moderator => true
      
      @user_message = Factory :message, :sender => @user, :recipient => @admin
      @admin_message = Factory :message, :sender => @admin, :recipient => @user
      @mod_message = Factory :message, :sender => @moderator, :recipient => @user
    end
    
    should_have_keys :zooniverse_user_id, :name, :email, :blocked_list, :moderator, :admin, :state, :created_at, :updated_at
    should_associate :comments, :collections, :live_collections, :messages, :sent_messages
    
    should "be #privileged?" do
      assert !@user.privileged?
      assert @admin.privileged?
      assert @moderator.privileged?
    end
    
    should "find #messages_with a user" do
      assert_same_elements [@user_message, @admin_message], @user.messages_with(@admin)
      assert_same_elements [@user_message, @admin_message], @admin.messages_with(@user)
      assert_equal [@mod_message], @user.messages_with(@moderator)
      assert_equal [@mod_message], @moderator.messages_with(@user)
    end
  end
  
  context "When banning a user that is already banned" do
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