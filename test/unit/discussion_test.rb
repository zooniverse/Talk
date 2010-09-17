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
        @live_collection = Factory :live_collection
        build_focus_for @live_collection
        @lc_discussion = @live_collection.discussions.first
        
        @collection = Factory :collection
        build_focus_for @collection
        @c_discussion = @collection.discussions.first
        
        @discussion = @asset.discussions.first
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
    
  end
end