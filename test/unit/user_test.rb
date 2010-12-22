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
      @moderator = Factory :user, :moderator => true
    end
    
    should "fail" do
      assert !@user.ban(@moderator)
    end
  end
  
  context "When banning a user" do
    setup do
      @user = Factory :user
      @moderator = Factory :user, :moderator => true
      @user.ban(@moderator)
    end
    
    should have_sent_email
  end
  
  context "When redeeming a user" do
    setup do
      @user = Factory :user, :state => 'banned'
      @moderator = Factory :user, :moderator => true
      @user.redeem(@moderator)
    end
    
    should have_sent_email
  end
  
  context "When determining if a user can modify" do
    setup do
      @asset = Factory :asset
      build_focus_for @asset
      collection_for @asset
      @live_collection = build_live_collection(2)
      
      @user = Factory :user
      @moderator = Factory :user, :moderator => true
    end
    
    context "an asset" do
      should "deny everybody" do
        assert_not @user.can_modify?(@asset)
        assert_not @moderator.can_modify?(@asset)
      end
    end
    
    context "a board" do
      should "deny everybody" do
        assert_not @user.can_modify?(Board.science)
        assert_not @moderator.can_modify?(Board.science)
      end
    end
    
    context "a comment" do
      should "allow only moderators and the owner" do
        assert @comment1.author.can_modify?(@comment1)
        assert @moderator.can_modify?(@comment1)
        assert_not @user.can_modify?(@comment1)
      end
    end
    
    context "a discussion" do
      should "allow only moderators and the owner" do
        assert @discussion.started_by.can_modify?(@discussion)
        assert @moderator.can_modify?(@discussion)
        assert_not @user.can_modify?(@discussion)
      end
    end
    
    context "a collection" do
      should "allow only moderators and the owner" do
        assert @collection.user.can_modify?(@collection)
        assert @moderator.can_modify?(@collection)
        assert_not @user.can_modify?(@collection)
      end
    end
    
    context "a live_collection" do
      should "allow only moderators and the owner" do
        assert @live_collection.user.can_modify?(@live_collection)
        assert @moderator.can_modify?(@live_collection)
        assert_not @user.can_modify?(@live_collection)
      end
    end
  end
end
