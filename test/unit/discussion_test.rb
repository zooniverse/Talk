require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  context "A Discussion" do
    setup do
      @asset = Factory :asset
      build_focus_for @asset
      @discussion2 = @asset2.discussions.first
      @discussion3 = @asset3.discussions.first
    end
    
    should_associate :comments
    should_include_modules :zooniverse_id, 'MongoMapper::Document'
    should_have_keys :zooniverse_id, :subject, :focus_id, :focus_type, :slug, :started_by_id,
                     :featured, :number_of_users, :number_of_comments, :popularity, :created_at, :updated_at
    
    should "#set_slug correctly" do
      assert_equal "monkey_is_an_oiii_emission", @discussion.slug
    end
    
    should "find the #focus" do
      assert_equal @asset, @discussion.focus
    end
    
    should "find the #most_recent" do
      assert_contains Discussion.most_recent, @discussion
      assert_contains Discussion.most_recent, @discussion2
      assert_contains Discussion.most_recent, @discussion3
    end
    
    should "find #trending" do
      assert_same_elements [@discussion, @discussion2, @discussion3], Discussion.trending(3)
    end
    
    should "find #mentioning" do
      assert_equal [@discussion], Discussion.mentioning(@asset)
    end
    
    should "#aggregate_comments" do
      assert_equal ['tag2', 'tag4', 'tag1'], @discussion.keywords
    end
    
    should "#update_counts" do
      assert_equal 3, @discussion.number_of_comments
      assert_equal 3, @discussion.number_of_users
      assert_equal 9, @discussion.popularity
    end
    
    context "being conveniently introspective" do
      setup do
        board_discussions_in Board.science, 1
        @b_discussion = Board.science.discussions.first
        
        @live_collection = Factory :live_collection
        build_focus_for @live_collection
        @lc_discussion = @live_collection.discussions.first
        
        @collection = Factory :collection
        build_focus_for @collection
        @c_discussion = @collection.discussions.first
        
        @discussion = @asset.discussions.first
      end
      
      should "know when it belongs to a board" do
        assert @b_discussion.board?
      end
      
      should "know when it belongs to a live collection" do
        assert @lc_discussion.live_collection?
      end
      
      should "know when it belongs to a collection" do
        assert @c_discussion.collection?
      end
      
      should "know when it belongs to an asset" do
        assert @discussion.asset?
      end
      
      should "know when it is a conversation" do
        assert @conversation.conversation?
        assert !@discussion.conversation?
      end
    end
    
    context "#destroy" do
      setup do
        @comments = @discussion.comments
        @discussion.destroy
      end
      
      should "destroy comments" do
        @comments.each do |comment|
          assert_raise(MongoMapper::DocumentNotFound) { comment.reload }
        end
      end
      
      should "be destroyed" do
        assert_raise(MongoMapper::DocumentNotFound) { @discussion.reload }
      end
      
      context "when it belongs to a board" do
        setup do
          board_discussions_in Board.science, 2
          @board_discussion = Board.science.discussions[0]
          @other_discussion = Board.science.discussions[1]
          @board_discussion.destroy
        end
        
        should "remove itself from the board" do
          assert_raise(MongoMapper::DocumentNotFound) { @board_discussion.reload }
          assert_nothing_raised { @other_discussion.reload }
          assert_equal [@other_discussion.id], Board.science.discussion_ids
        end
      end
    end
  end
end
