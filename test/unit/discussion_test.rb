require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  context "A Discussion" do
    setup do
      @asset = Factory :asset
      build_focus_for @asset
      @discussion2 = @asset2.discussions.first
      @discussion3 = @asset3.discussions.first
    end
    
    should "have keys" do
      [:zooniverse_id, :subject, :tags, :mentions, :focus_id, :focus_type,
       :slug, :created_at, :updated_at, :number_of_users, :number_of_comments].each do |key|
        assert @discussion.respond_to?(key)
      end
    end

    should "have correct associations" do
      assert @discussion.comments.include?(@comment1)
      assert @discussion.associations.keys.include?("comments")
    end
    
    should "#set_slug correctly" do
      assert_equal "monkey_is_an_oiii_emission", @discussion.slug
    end
    
    should "find the #focus" do
      assert_equal @asset, @discussion.focus
    end
    
    should "find the #most_recent" do
      assert Discussion.most_recent.include? @discussion
      assert Discussion.most_recent.include? @discussion2
      assert Discussion.most_recent.include? @discussion3
    end
    
    should "find #trending" do
      assert Discussion.trending(3).include? @discussion
      assert Discussion.trending(3).include? @discussion2
      assert Discussion.trending(3).include? @discussion3
      assert !Discussion.trending(3).include?(@asset.conversation)
    end
    
    should "find #mentioning" do
      assert_equal [@discussion], Discussion.mentioning(@asset)
    end
    
    should "#aggregate_comments" do
      assert_equal ['tag2', 'tag4', 'tag1'], @discussion.tags
      assert_equal [@asset.zooniverse_id], @discussion.mentions
    end
    
    should "#update_counts" do
      assert_equal 3, @discussion.number_of_comments
      assert_equal 3, @discussion.number_of_users
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
    end
    
  end
end