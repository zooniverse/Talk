require 'test_helper'

class LiveCollectionTest < ActiveSupport::TestCase
  context "A LiveCollection" do
    setup do 
      @collection = Factory :live_collection, :tags => ["Tag1", "TAG2"]
    end
    
    should_have_keys :zooniverse_id, :name, :description, :tags, :user_id
    should_associate :user
    should_include_modules :focus, :zooniverse_id, 'MongoMapper::Document'
    
    context "generating zooniverse_ids" do
      setup do
        @collections = []
        
        1.upto(35){ |i| @collections << Factory(:live_collection) }
      end
      
      should "increment 9 to a" do
        assert_equal "CMZL00000a", @collections[8].zooniverse_id
      end
      
      should "increment z to 1" do
        assert_equal "CMZL000010", @collections[34].zooniverse_id
      end
    end
    
    context "Finding #assets" do
      setup do
        @asset = Factory :asset
        build_focus_for @asset
      end
      
      should "find tag-matched assets" do
        assert_same_elements [@asset, @asset2, @asset3], @collection.assets
      end
    end
    
    should "find #recent" do
      assert_equal [@collection], LiveCollection.recent
    end
    
    context "#destroy" do
      setup do
        build_focus_for @collection
        3.times{ conversation_for @collection }
        
        @conversation = @collection.conversation
        @discussions = @collection.discussions
        @document_hash = @collection.to_mongo
        
        @conversation.comments.first.body = "Edited"
        @conversation.comments.first.save
        
        @document_hash['conversation'] = @conversation.to_embedded_hash
        @document_hash['discussions'] = @collection.discussions.collect(&:to_embedded_hash)
        
        @collection.archive_and_destroy_as @collection.user
        @archive = Archive.first(:kind => "LiveCollection", :original_id => @collection.id)
      end
      
      should "remove collection, discussions, and comments" do
        assert_raise(MongoMapper::DocumentNotFound) { @collection.reload }
        
        assert_raise(MongoMapper::DocumentNotFound) { @conversation.reload }
        @conversation.comments.each do |comment|
          assert_raise(MongoMapper::DocumentNotFound) { comment.reload }
        end
        
        @discussions.each do |discussion|
          assert_raise(MongoMapper::DocumentNotFound) { discussion.reload }
          
          discussion.comments.each do |comment|
            assert_raise(MongoMapper::DocumentNotFound) { comment.reload }
          end
        end
      end
      
      should "Archive collection" do
        assert_equal "LiveCollection", @archive.kind
        assert_equal @collection.id, @archive.original_id
        assert_equal @collection.zooniverse_id, @archive.zooniverse_id
        assert_equal @collection.user_id, @archive.user_id
        assert_equal @collection.user_id, @archive.destroying_user_id
        assert_equal @document_hash, @archive.original_document
      end
      
      should "not Archive discussions and comments separately" do
        assert_not Archive.exists?(:kind => "Comment")
        assert_not Archive.exists?(:kind => "Discussion")
        assert_equal 1, Archive.count
      end
    end
  end
end