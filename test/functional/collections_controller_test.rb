require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase 
  context "Collections controller" do
    setup do
      @controller = CollectionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "#show not logged in" do
      setup do
        @collection = build_collection
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
      
      should "display mentions list" do
        assert_select '.rhc .panel:nth-child(2) h2', :text => 'Mentions'
        assert_select '.rhc .panel:nth-child(2) .inner ul li a', :text => @discussion.subject
      end
      
      should "display collection tags" do
        assert_select '#tags-for-focus h2', :text => I18n.t('homepage.keywords')
        assert_select '#tags-for-focus ul li a', :text => @collection.keywords.first
      end
      
      should "display collection assets" do
        assert_select ".collection-viewer > a", @collection.assets.length
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
        @collection = build_collection
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
        @collection = build_collection
        standard_cas_login(@collection.user)
        get :edit, { :id => @collection.zooniverse_id }
      end
      
      should respond_with :success
      should render_template :edit
    end
      
    context "#create Collection" do
      setup do
        @asset = Factory :asset
        standard_cas_login
        
        options = {
          :collection_kind => {
            :id => "Collection"
          },
          :collection => {
            :name => "My Collection",
            :description => "Is awesome",
            :asset_ids => [@asset.id],
            :user_id => @user.id
          }
        }
        post :create, options
      end
      
      should set_the_flash.to(I18n.t('controllers.collections.flash_create'))
      should respond_with :found
      should "redirect to collection page" do
        assert_redirected_to collection_path(assigns(:collection).zooniverse_id)
      end
    end
    
    context "#create LiveCollection" do
      setup do
        standard_cas_login
        
        options = {
          :collection_kind => {
            :id => "Live Collection"
          },
          :keyword => {
            1 => 'tag1',
            2 => 'tag2'
          },
          :collection => {
            :name => "My Collection",
            :description => "Is awesome",
            :user_id => @user.id
          }
        }
        post :create, options
      end
      
      should set_the_flash.to(I18n.t('controllers.collections.flash_create'))
      should respond_with :found
      should "redirect to collection page" do
        assert_redirected_to live_collection_path(assigns(:collection).zooniverse_id)
      end
    end
    
    context "#update Collection" do
      setup do
        @collection = Factory :collection
        standard_cas_login(@collection.user)
        
        options = {
          :id => @collection.id,
          :collection_kind => {
            :id => "Collection"
          },
          :collection => {
            :description => "Is more awesome"
          }
        }
        post :update, options
      end
      
      should set_the_flash.to(I18n.t('controllers.collections.flash_updated'))
      should respond_with :found
      should "redirect to collection page" do
        assert_redirected_to collection_path(assigns(:collection).zooniverse_id)
      end
      
      should "update values" do
        assert_equal "Is more awesome", @collection.reload.description
      end
    end
    
    context "#update LiveCollection" do
      setup do
        @collection = Factory :live_collection
        standard_cas_login(@collection.user)
        
        options = {
          :id => @collection.id,
          :collection_kind => {
            :id => "Live Collection"
          },
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
    
    context "#destroy Collection by owner" do
      setup do
        @collection = Factory :collection
        standard_cas_login(@collection.user)
        post :destroy, { :id => @collection.zooniverse_id, :collection_kind => "Collection" }
      end
      
      should set_the_flash.to(I18n.t('controllers.collections.flash_destroyed'))
      should respond_with :found
      should "redirect to collections" do
        assert_redirected_to collections_path
      end
      
      should "destroy collection" do
        assert_raise(MongoMapper::DocumentNotFound) { @collection.reload }
      end
    end
    
    context "#destroy LiveCollection by owner" do
      setup do
        @collection = Factory :live_collection
        standard_cas_login(@collection.user)
        post :destroy, { :id => @collection.zooniverse_id, :collection_kind => "Live Collection" }
      end
      
      should set_the_flash.to(I18n.t('controllers.collections.flash_destroyed'))
      should respond_with :found
      should "redirect to collections" do
        assert_redirected_to collections_path
      end
      
      should "destroy collection" do
        assert_raise(MongoMapper::DocumentNotFound) { @collection.reload }
      end
    end
    
    context "#destroy by other user" do
      setup do
        @collection = Factory :collection
        standard_cas_login
        post :destroy, { :id => @collection.zooniverse_id, :collection_kind => "Collection" }
      end
      
      should set_the_flash.to(I18n.t('controllers.collections.not_yours'))
      should respond_with :found
      should "redirect to collections" do
        assert_redirected_to collections_path
      end
      
      should "not destroy collection" do
        assert !@collection.reload.destroyed?
      end
    end
    
    context "#add" do
      setup do
        @asset = Factory :asset
        @collection = build_collection
        standard_cas_login(@collection.user)
        post :add, { :id => @collection.zooniverse_id, :asset_id => @asset.id, :format => :js }
      end
      
      should respond_with :success
      should "add asset" do
        assert_contains @collection.reload.asset_ids, @asset.id
      end
    end
    
    context "#remove" do
      setup do
        @asset = Factory :asset
        @collection = Factory :collection, :asset_ids => [ @asset.id ]
        standard_cas_login(@collection.user)
        post :remove, { :id => @collection.zooniverse_id, :asset_id => @asset.id, :format => :js }
      end
      
      should respond_with :success
      should "remove asset" do
        assert_does_not_contain @collection.reload.asset_ids, @asset.id
      end
    end
  end
end
