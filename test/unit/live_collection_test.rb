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
    
    should "find #most_recent" do
      assert_equal [@collection], LiveCollection.most_recent
    end
    
    context "#destroy" do
      setup do
        build_focus_for @collection
        3.times{ conversation_for @collection }
        
        @collection_hash = @collection.to_mongo
        
        @conversation = @collection.conversation
        @conversation_hash = @conversation.to_embedded_hash
        
        @discussions = @collection.discussions
        @discussions_hash = @collection.discussions.collect(&:to_embedded_hash)
        
        @collection.destroy
        @archive = ArchivedCollection.find_by_zooniverse_id(@collection.zooniverse_id)
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
      
      should "create ArchivedCollection" do
        assert_equal @collection.user_id, @archive.user_id
        assert_equal @collection_hash, @archive.collection_archive
        assert_equal @conversation_hash, @archive.conversation_archive
        assert_same_elements @discussions_hash, @archive.discussions_archive
      end
    end
  end
end