require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase 
  context "Collections controller" do
    setup do
      @controller = CollectionsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    context "When requesting a Collection" do
      setup do
        @collection = Factory :collection
        @conversation  = Factory :conversation, :focus_id => @collection.id, :focus_type => "Collection"
        @collection.conversation_id = @conversation.id
        @collection.save
        @focus = @collection
        @mentions = Discussion.mentioning(@collection)
        @comment = Comment.new
        @comments = @collection.conversation.comments
        @discussion = @conversation
        get :show, { :id => @collection.zooniverse_id }
      end

      should respond_with :success
      should render_template :show
      
      should "Display the collection name" do
        assert_select 'h1.collection-title', :text => "#{@collection.name} by #{@collection.user.name}"
      end
    end
  end
end