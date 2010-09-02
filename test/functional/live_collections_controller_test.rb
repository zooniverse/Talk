require 'test_helper'

class LiveCollectionsControllerTest < ActionController::TestCase
  context "Live Collections Controller" do
    setup do
      @controller = LiveCollectionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "#show not logged in" do
      setup do
        @collection = build_live_collection
        build_focus_for @collection
        conversation_for @collection
        get :show, { :id => @collection.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "Display the collection name" do
        assert_select 'h1.collection-title', :text => "#{@collection.name} by #{@collection.user.name}"
      end
      
      should "display discussions list" do
        assert_select '.rhc .panel h2', :text => '1 Discussion'
        assert_select '.rhc .panel .inner ul li a', :text => @discussion.subject
      end
      
      should_eventually "display mentions list" do
        assert_select '.rhc .panel:nth-child(2) h2', :text => 'Mentions'
        assert_select '.rhc .panel:nth-child(2) .inner ul li a', :text => @discussion.subject
      end
      
      should "display collection tags" do
        assert_select '#tags-for-focus h2', :text => I18n.t('homepage.keywords')
        assert_select '#tags-for-focus ul li a', :text => @collection.tags.first
      end
      
      should "display collection assets" do
        assert_select ".collection-viewer > a", 5
      end
      
      should "display login" do
        assert_select '#not-logged-in'
      end
      
      should "display comment list" do
        assert_select '.comment-container .comment-body'
        assert_select '.comment-container .comment-body .name', :text => @conversation.comments.first.author.name
      end
    end
    
    context "#show logged in as creator" do
      setup do
        @collection = build_live_collection
        build_focus_for @collection
        conversation_for @collection
        standard_cas_login(@collection.user)
        get :show, { :id => @collection.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "display edit link" do
        assert_select ".asset-actions ul li a", :text => "Edit"
      end
      
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
    
    context "#edit" do
      setup do
        @collection = build_live_collection
        standard_cas_login(@collection.user)
        get :edit, { :id => @collection.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :edit
    end
  end
  
  context "#update" do
    setup do
      @collection = Factory :live_collection
      standard_cas_login(@collection.user)
      
      options = {
        :id => @collection.id,
        :keyword => {
          1 => 'big',
          2 => 'purple',
          3 => 'truck'
        }
      }
      post :update, options
    end
    
    should set_the_flash.to(I18n.t('controllers.collections.flash_updated'))
    should respond_with :found
    should "redirect to collection page" do
      assert_redirected_to live_collection_path(assigns(:collection).zooniverse_id)
    end
    
    should "update values" do
      assert_same_elements %w(big purple truck), @collection.reload.tags
    end
  end
end
