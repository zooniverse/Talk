require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  context "A message" do
    setup do
      @message = Factory :message
      @user = Factory :user
    end
    
    should_have_keys :title, :body, :unread, :sender_id, :destroyed_by_sender, :recipient_id, :destroyed_by_recipient
    should_associate :sender, :recipient
    should_include_modules 'MongoMapper::Document'
    
    should "toggle unread status" do
      assert @message.unread
      @message.mark_as_read
      @message.reload
      assert !@message.unread
    end
    
    should "return #recipient_name" do
      assert_equal @message.recipient.name, @message.recipient_name
    end
    
    should "set #recipient_name=" do
      @message.recipient_name = @user.name
      assert_equal @user, @message.recipient
    end
    
    should "know if it was #sent_to? a user" do
      assert @message.sent_to?(@message.recipient)
      assert !@message.sent_to?(@message.sender)
    end
    
    should "know if it was #sent_by? a user" do
      assert @message.sent_by?(@message.sender)
      assert !@message.sent_by?(@message.recipient)
    end
    
    should "not be #visible_to? other users" do
      other = Factory :user
      assert @message.visible_to?(@message.recipient)
      assert @message.visible_to?(@message.sender)
      assert !@message.visible_to?(other)
    end
    
    should "#destroy_for each user" do
      @message.destroy_for @message.recipient
      assert !@message.destroyed?
      @message.destroy_for @message.sender
      assert @message.destroyed?
    end
    
    context "blocked by recipient" do
      setup do
        @recipient = Factory :user
        @recipient.blocked_list << @message.sender.id
        @recipient.save
        @message.recipient = @recipient
      end

      should "not be valid" do
        assert !@message.valid?
      end
    end
  end
end