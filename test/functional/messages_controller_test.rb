require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  context "A MessagesController when NOT logged in" do
    setup do
      @controller = MessagesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should_eventually "be redirected" do
        assert_redirected_to "The CAS login url"
      end
    end
  end
  
  context "A MessagesController when logged in" do
    setup do
      @controller = MessagesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      standard_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
    
    context "#sent" do
      setup do
        get :sent
      end
      
      should respond_with :success
      should render_template :sent
    end
    
    context "#show" do
      setup do
        @sender = Factory :user        
        @message = Factory :message, :sender => @sender, :recipient => @user
        get :show, { :id => @message.id }
      end
      
      should respond_with :success
      should render_template :show
    end
    
    context "#new" do
      setup do
        get :new
      end
      
      should respond_with :success
      should render_template :new
    end
    
    # FIXME
    context "#create when not blocked" do
      setup do
        @message = Factory :message
        options = {
          :sender_id => @message.sender.id,
          :recipient_id => @message.recipient.id,
          :title => "HI",
          :body => "AWESOME!"
        }
          
        post :create, options
      end
      
      should_eventually "create" do
        respond_with :success
      end
      
      should_eventually "be redirected" do
        assert_redirected_to "/messages"
      end
    end
    
    # FIXME
    context "#create when blocked" do
      setup do
        @message = Factory :message
        @recipient = Factory :user
        @recipient.blocked_list << @message.sender.id
        @recipient.save
        @message.recipient = @recipient
        
        options = {
          :sender_id => @message.sender.id,
          :recipient_id => @recipient.id,
          :title => "BLAH!",
          :body => "blocked :("
        }
          
        post :create, options
      end
      
      should_eventually "create" do
        respond_with :success
      end
      
      should_eventually "render edit" do
        render_template :edit
      end
    end
  end
end
