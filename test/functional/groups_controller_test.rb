require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  context "A GroupsController" do
    setup do
      @controller = GroupsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "When requesting a Group not logged in" do
      setup do
        build_group
        build_focus_for @group
        conversation_for @group
        
        get :show, { :id => @group.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :show
      
      should "Display the group zooniverse_id" do
        assert_select '.collection-title', :text => /Star.*#{ @group.zooniverse_id }.*/m
      end
      
      should "display group tags" do
        assert_select '#tags-for-focus h2', :text => /keywords/i
        assert_select '#tags-for-focus ul li a', :text => @group.tags.first
      end
      
      should "display assets" do
        assert_select '.collection-thumbnail', 5
      end
      
      should "display login" do
        assert_select '#not-logged-in'
      end
      
      should "display short comment list" do
        assert_select '.short-comments'
        assert_select '.short-comments .short-comment:nth-child(1) .body .name a', :text => @conversation.comments.first.author.name
      end
      
      should "display discussions list" do
        assert_select '.rhc .discussions'
        assert_select '.rhc .discussions .discussion:nth-child(2) p a', :text => @discussion.subject
      end
    end
    
    context "When requesting a group logged in" do
      setup do
        build_group
        build_focus_for @group
        conversation_for @group
        standard_cas_login
        
        get :show, { :id => @group.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :show
      
      should "display short comment form" do
        assert_select '.short-comment-form form'
      end
      
      should "display upvoting" do
        assert_select '.vote-controls span a', :text => "RECOMMEND"
      end
      
      should "display reporting" do
        assert_select '.vote-controls span a', :text => "REPORT"
      end
    end
  end
end