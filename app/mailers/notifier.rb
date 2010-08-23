class Notifier < ActionMailer::Base
  default :from => "your@email.com"
  
  def notify_banned_user(user)
    @user = user
    attachments["sad-face.png"] = File.read("#{Rails.root}/public/images/sad-face.png")
    mail(:to => "#{user.name} <#{user.email}>", :subject => "You have been banned")
  end
  
  def notify_redeemed_user(user)
    @user = user
    attachments["happy-face.png"] = File.read("#{Rails.root}/public/images/happy-face.png")
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Welcome back")
  end
end
