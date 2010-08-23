class Notifier < ActionMailer::Base
  default :from => "your@email.com"
  
  def notify_banned_user(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "You have been banned")
  end
  
  def notify_redeemed_user(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Welcome back")
  end
end
