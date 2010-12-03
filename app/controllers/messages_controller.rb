class MessagesController < ApplicationController
  respond_to :html, :json
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :get_meta, :except => :recipient_search
  
  def index
    @listing = true
    @messages = current_zooniverse_user.messages
  end
  
  def sent
    @listing = false
    @messages = current_zooniverse_user.sent_messages
  end
  
  def show
    @listing = false
    @message = Message.find(params[:id])
        
    if !@message.nil? && @message.visible_to?(current_zooniverse_user)
      @message.mark_as_read
      @thread_with_user = @message.sender
      @messages = current_zooniverse_user.messages_with(@message.sender)
    end
  end
  
  def new
    @message = Message.new
    @recipient_name = params[:recipient_name] if params[:recipient_name]
  end
  
  def create
    @recipient = User.find_by_name(params[:message][:recipient_name])
    if @recipient.nil?
      options = {}
    else
      options = { :sender_id => current_zooniverse_user.id, :recipient_id => @recipient.id }
    end
    
    @message = Message.new(params[:message].merge(options))
    
    if @message.save
      flash[:notice] = I18n.t 'controllers.messages.flash_create'
      redirect_to messages_path
    else
      flash_model_errors_on(@message)
      render :action => "new"
    end
  end
  
  def destroy
    @message = Message.find(params[:id])
    @message.destroy_for(current_zooniverse_user)
    flash[:notice] = I18n.t 'controllers.messages.flash_destroyed'
    redirect_to messages_path
  end
  
  def recipient_search
    @names = User.limit(5).only(:name).all(:name => /^#{ params[:term] }/)
    respond_with(@names.collect{ |u| u.name }.to_json)
  end
  
  private
  def get_meta
    @unread = current_zooniverse_user.messages.all(:unread => true)
    @conversations = current_zooniverse_user.messages.collect{ |message| message.sender }.uniq
  end
end
