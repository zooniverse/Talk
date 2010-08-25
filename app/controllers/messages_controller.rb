class MessagesController < ApplicationController
  respond_to :html, :json
  before_filter :check_or_create_zooniverse_user
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
  end
  
  def create
    @recipient = User.find_by_name(params["message"][:recipient_name])
    options = { :sender_id => current_zooniverse_user.id, :recipient_id => @recipient.id } unless @recipient.nil?
    params["message"].delete(:recipient_name)
    @message = Message.new(params[:message].merge(options))
    
    if @message.save
      flash[:notice] = I18n.t 'controllers.messages.flash_create'
      redirect_to messages_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @message = Message.find(params[:id])
    @message.destroy_for(current_zooniverse_user)
  end
  
  def recipient_search
    @names = User.limit(5).only(:name).all(:name => /^#{ params[:term] }/)
    respond_with(@names.collect{ |u| u.name }.to_json)
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
