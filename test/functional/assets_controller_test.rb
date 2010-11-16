require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  context "Assets Controller" do
    setup do
      @controller = AssetsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "When requesting an Asset not logged in" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        conversation_for @asset
        collection_for @asset
        
        get :show, { :id => @asset.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :show
      
      should "Display the asset zooniverse_id" do
        assert_select '#asset-as-focus h1', :text => /.*#{ @asset.zooniverse_id }.*/
      end
      
      should "display asset tags" do
        # assert_select '#tags-for-focus h2', :text => I18n.t('homepage.keywords')
        # assert_select '#tags-for-focus ul li a', :text => @asset.tags.first
      end
      
      should "display asset" do
        assert_select '#asset-as-focus .asset-actions ul li a', :text => "Examine"
      end
      
      should "display login" do
        assert_select '#not-logged-in'
      end
      
      should "display short comment list" do
        assert_select '.short-comments'
        assert_select '.short-comments .short-comment:nth-child(1) .body .name a', :text => @conversation.comments.first.author.name
      end
      
      should "display collection list" do
        assert_select '.rounded-panel .collection:nth-child(1) h2 a', :text => @collection.name
      end
      
      should "display discussions list" do
        assert_select '.rhc .discussions'
        assert_select '.rhc .discussions .discussion:nth-child(2) p a', :text => @discussion.subject
      end
    
    end
    
    context "When requesting an Asset logged in" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
        conversation_for @asset
        standard_cas_login
        
        get :show, { :id => @asset.zooniverse_id }
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
      
      should "display collect this asset" do
        assert_select '#asset-as-focus .asset-actions a.collect-asset'
      end
    end
  end
end
