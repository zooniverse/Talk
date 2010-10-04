require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  context "A HomeController" do
    setup do
      @controller = HomeController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index not logged in" do
      setup do
        CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(true)
        get :index
      end
      
      should respond_with :success
      should render_template :index
      
      %w(assets collections discussions comments).each do |kind|
        context "showing #recent_#{kind}" do
          setup do
            get "recent_#{kind}".to_sym, { :format => :js }
          end
          
          should respond_with :success
          should render_template kind.to_sym
        end
      end
      
      %w(help science chat).each do |kind|
        context "showing #recent_#{kind}" do
          setup do
            get "recent_#{kind}".to_sym, { :format => :js }
          end
          
          should respond_with :success
          should render_template :discussions
        end
      end
      
      %w(assets collections discussions keywords).each do |kind|
        context "showing #trending_#{kind}" do
          setup do
            get "trending_#{kind}".to_sym, { :format => :js }
          end
          
          should respond_with :success
          should render_template kind.to_sym
        end
      end
      
      should "Show about box" do
        assert_select "#about-box"
      end
    end
    
    context "#cas_test logged in" do
      setup do
        standard_cas_login
        get :cas_test
      end

      should respond_with :success
    end
  end
end
