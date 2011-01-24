class MessagesController < ApplicationController
  respond_to :html, :json, :js
  before_filter CASClient::Frameworks::Rails::Filter, :except => [:recipient_search, :preview]
  before_filter :get_meta, :except => [:recipient_search, :preview]
  
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
    @showing = Message.find(params[:id])
    return not_found unless @showing
    @message = Message.new
    
    if !@showing.nil? && @showing.visible_to?(current_zooniverse_user)
      @showing.mark_as_read
      @thread_with_user = @showing.sender
      @messages = current_zooniverse_user.messages_with(@showing.sender)
      @last_title = @messages.any? ? @messages.first.title : ""
    end
  end
  
  def new
    @message = Message.new
    @recipient_name = params[:recipient_name] if params[:recipient_name]
  end
  
  def create
    @message = Message.new(params[:message])
    @recipient_name = params[:message][:recipient_name]
    @recipient = User.find_by_name(@recipient_name)
    @message.sender = current_zooniverse_user
    @message.recipient = @recipient
    
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
    return not_found unless @message
    
    @message.destroy_for(current_zooniverse_user)
    flash[:notice] = I18n.t 'controllers.messages.flash_destroyed'
    redirect_to messages_path
  end
  
  def recipient_search
    @names = User.limit(5).only(:name).all(:name => /^#{ params[:term] }/i)
    respond_with(@names.collect{ |u| u.name }.to_json)
  end
  
  def preview
    message = Message.new(:body => params[:body] || "")
    message.recipient = User.first(:name => params[:recipient]) if params[:recipient] && !params[:recipient].blank?
    message.sender = current_zooniverse_user
    message.update_timestamps
    
    @listing = false
    
    respond_with(@message) do |format|
      format.js do
        render :update do |page|
          page[".new-message-preview"].html(render :partial => "message", :locals => { :message => message })
        end
      end
    end
  end
  
  private
  def get_meta
    @unread = current_zooniverse_user.messages.all(:unread => true)
    @conversations = current_zooniverse_user.messages.collect{ |message| message.sender }.uniq
  end
end
