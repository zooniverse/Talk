require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  context "A MessagesController" do
    setup do
      @controller = MessagesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index" do
      setup do
        standard_cas_login
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
    
    context "#sent" do
      setup do
        standard_cas_login
        get :sent
      end
      
      should respond_with :success
      should render_template :sent
    end
    
    context "#show" do
      setup do
        @sender = Factory :user
        @message = Factory :message, :sender => @sender
        standard_cas_login(@sender)
        get :show, { :id => @message.id }
      end
      
      should respond_with :success
      should render_template :show
    end
    
    context "#new" do
      setup do
        standard_cas_login
        get :new
      end
      
      should respond_with :success
      should render_template :new
    end
    
    context "#create when not blocked" do
      setup do
        @sender = Factory :user
        @recipient = Factory :user
        
        options = {
          :message => {
            :recipient_name => @recipient.name,
            :title => "HI",
            :body => "AWESOME!"
          }
        }
        
        standard_cas_login(@sender)
        post :create, options
      end
      
      should respond_with :found
      
      should "redirect to messages" do
        assert_redirected_to messages_path
      end
    end
    
    context "#create when blocked" do
      setup do
        @sender = Factory :user
        @recipient = Factory :user
        @recipient.blocked_list << @sender.id
        @recipient.save
        
        options = {
          :message => {
            :recipient_name => @recipient.name,
            :title => "BLAH!",
            :body => "blocked :("
          }
        }
        
        standard_cas_login(@sender)
        post :create, options
      end
      
      should respond_with :success
      should render_template :edit
    end
    
    context "#create with no recipient" do
      setup do
        @sender = Factory :user
        @recipient = Factory :user
        @recipient.blocked_list << @sender.id
        @recipient.save
        
        options = {
          :message => {
            :title => "BLAH!",
            :body => "blocked :("
          }
        }
        
        standard_cas_login(@sender)
        post :create, options
      end
      
      should respond_with :success
      should render_template :edit
    end
  end
end
