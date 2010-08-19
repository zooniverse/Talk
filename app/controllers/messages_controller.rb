class MessagesController < ApplicationController
  before_filter :check_or_create_zooniverse_user, :get_meta
  
  def index
    @messages = current_zooniverse_user.messages
  end
  
  def sent
    @messages = current_zooniverse_user.sent_messages
  end
  
  def show
    @message = Message.find(params[:id])
  end
  
  private
  # FIXME - I am bad codes
  def get_meta
    @unread = current_zooniverse_user.messages
    @conversations = current_zooniverse_user.messages.collect{ |message| message.sender }.uniq
  end
end
