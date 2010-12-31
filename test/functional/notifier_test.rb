require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  context "A Notifier" do
    setup do
      @mailer = Notifier
    end
    
    context "#notify_banned_user" do
      setup do
        @user = Factory :user
        @email = @mailer.notify_banned_user(@user).deliver
      end
      
      should "send email" do
        assert ActionMailer::Base.deliveries.any?, "email didn't send"
        assert_equal [@user.email], @email.to
        assert_equal "You have been banned", @email.subject
      end
    end
    
    context "#notify_redeemed_user" do
      setup do
        @user = Factory :user
        @email = @mailer.notify_redeemed_user(@user).deliver
      end
      
      should "send email" do
        assert ActionMailer::Base.deliveries.any?, "email didn't send"
        assert_equal [@user.email], @email.to
        assert_equal "Welcome back", @email.subject
      end
    end
    
    context "#message_received" do
      setup do
        @message = Factory :message
        @email = @mailer.message_received(@message).deliver
      end
      
      should "send email" do
        assert ActionMailer::Base.deliveries.any?, "email didn't send"
        assert_equal [@message.recipient.email], @email.to
        assert_equal "New message from #{@message.sender.name}", @email.subject
      end
    end
    
    context "#notify_reported_user" do
      setup do
        @user = Factory :user
        @moderator = Factory :user, :moderator => true
        @reporter = Factory :user
        @email = @mailer.notify_reported_user(@user, @moderator, @reporter).deliver
      end
      
      should "send email" do
        assert ActionMailer::Base.deliveries.any?, "email didn't send"
        assert_equal [@moderator.email], @email.to
        assert_equal "#{@user.name} has been reported by #{@reporter.name}", @email.subject
      end
    end
  end
end
