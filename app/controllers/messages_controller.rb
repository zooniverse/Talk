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
    @message.mark_as_read unless @message.nil?
    @thread_with_user = @message.sender
    @messages = current_zooniverse_user.messages_with(@message.sender)
  end
  
  def new
    @message = Message.new
  end
  
  def create
    @recipient = User.find_by_name(params["message"][:recipient_name])
    options = { :sender_id => current_zooniverse_user.id, :recipient_id => @recipient.id } unless @recipient.nil?
    params["message"].delete(:recipient_name)
    logger.debug "PARAMS:@"
    logger.debug params.inspect
    @message = Message.new(params[:message].merge(options))
    
    if @message.save
      flash[:notice] = I18n.t 'messages.created'
      redirect_to messages_path
    else
      render :action => "edit"
    end
  end
  
  private
  def get_meta
    if current_zooniverse_user.nil?
      redirect_to "/cas_test"
      return false
    end
    
    @unread = current_zooniverse_user.messages.select{ |message| message.unread }
    @conversations = current_zooniverse_user.messages.collect{ |message| message.sender }.uniq
  end
end
