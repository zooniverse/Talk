# The Mailer
class Notifier < ActionMailer::Base
  default :from => "your@email.com"
  
  # Email banned User
  # @param user [User] The User to notify
  def notify_banned_user(user)
    @user = user
    # attachments["sad-face.png"] = File.read("#{Rails.root}/public/images/sad-face.png")
    mail(:to => "#{user.name} <#{user.email}>", :subject => "You have been banned")
  end
  
  # Email redeemed User
  # @param user [User] The User to notify
  def notify_redeemed_user(user)
    @user = user
    # attachments["happy-face.png"] = File.read("#{Rails.root}/public/images/happy-face.png")
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Welcome back")
  end
  
  # Email a User when they receive a new Message
  # @param message [Message] The Message being delivered
  def message_received(message)
    @user = message.recipient
    @message = message
    mail(:to => "#{@user.name} <#{@user.email}>", :subject => "New message from #{message.sender.name}")    
  end
  
  # Email moderators about a reported User
  # @param user [User] The User being reported
  # @param recipient [User] The User being notified
  # @param reporter [User] The reporting User
  def notify_reported_user(user, recipient, reporter)
    @user = user
    @moderator = recipient
    @reporter = reporter
    mail(:to => "#{recipient.name} <#{recipient.email}>", :subject => "#{user.name} has been reported by #{reporter.name}")    
  end
end
