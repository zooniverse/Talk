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
    should_have_keys :zooniverse_id, :subject, :focus_id, :focus_type, :started_by_id,
                     :featured, :number_of_users, :number_of_comments, :popularity, :created_at, :updated_at
    
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
      assert_equal 6, @discussion.popularity
    end
    
    context "#count_new_comments" do
      setup do
        @comment1.set :created_at => 30.minutes.ago
        @comment2.set :created_at => 1.hour.ago
        @comment3.set :created_at => Time.now.utc
        
        @comment1.author.set :last_login_at => 1.hour.ago
        @comment1.author.reload
      end
      
      should "#count_new_comments for a user" do
        assert_equal 3, @discussion.count_new_comments(:for_user => @comment1.author)
        assert_equal 2, @discussion.count_new_comments(:for_user => @comment1.author, :since => 1.hour.ago)
      end
      
      should "#count_new_comments for a new user" do
        assert_equal 3, @discussion.count_new_comments(:for_user => Factory(:user))
        assert_equal 2, @discussion.count_new_comments(:for_user => Factory(:user), :since => 1.hour.ago)
      end
      
      should "#count_new_comments without a user" do
        assert_equal 3, @discussion.count_new_comments
        assert_equal 2, @discussion.count_new_comments(:since => 1.hour.ago)
        assert_equal 2, @discussion.count_new_comments(:for_user => nil, :since => 1.hour.ago)
      end
    end
    
    context "finding discussions with new comments" do
      setup do
        2.times{ build_discussions_for @asset }
        @discussion2 = @asset.discussions[1]
        @discussion3 = @asset.discussions[2]
        
        @comment1 = @discussion.comments.first
        @comment2 = @discussion2.comments.first
        @comment1.author.set :last_login_at => 1.hour.ago
        @comment1.author.reload
        
        @comment2.author_id = @comment1.author.id
        @comment2.save
        @discussion2.save
        @discussion2.reload
        
        @conversation.set :updated_at => 30.minutes.ago
        @conversation.reload
        
        @discussion2.set :updated_at => 45.minutes.ago
        @discussion2.reload
        
        @discussion3.set :updated_at => 2.days.ago
        @discussion3.reload
        
        Discussion.collection.update({
          :focus_id => { :$ne => @asset.id }
        }, {
          :$set => { :updated_at => 1.year.ago.utc }
        }, :multi => true)
      end
      
      should "find discussions #with_new_comments for an existing user" do
        assert_equal [@discussion, @conversation, @discussion2], Discussion.with_new_comments(:for_user => Factory(:user, :last_login_at => 1.day.ago))
        assert_equal [@discussion, @conversation], Discussion.with_new_comments(:for_user => Factory(:user, :last_login_at => 1.day.ago), :per_page => 2)
        assert_equal [@conversation], Discussion.with_new_comments(:for_user => Factory(:user, :last_login_at => 1.day.ago), :per_page => 1, :page => 2)
        
        assert_equal [@discussion, @discussion2], Discussion.with_new_comments(:for_user => @comment1.author, :by_user => true)
        assert_equal [@discussion], Discussion.with_new_comments(:for_user => @comment1.author, :by_user => true, :read_list => [@discussion2.id])
        assert_equal [], Discussion.with_new_comments(:for_user => @comment1.author, :by_user => true, :since => 30.minutes.ago, :read_list => [@discussion.id])
      end
      
      should "find discussions #with_new_comments for a new user" do
        assert_equal [@discussion, @conversation, @discussion2], Discussion.with_new_comments(:for_user => Factory(:user))
        assert_equal [@discussion], Discussion.with_new_comments(:for_user => Factory(:user), :per_page => 1)
        assert_equal [@discussion, @conversation], Discussion.with_new_comments(:for_user => Factory(:user), :per_page => 2)
        assert_equal [@conversation], Discussion.with_new_comments(:for_user => Factory(:user), :per_page => 1, :page => 2)
        
        assert_equal [], Discussion.with_new_comments(:for_user => Factory(:user), :by_user => true)
        assert_equal [@conversation], Discussion.with_new_comments(:for_user => Factory(:user), :read_list => [@discussion.id], :per_page => 1)
        assert_equal [@conversation], Discussion.with_new_comments(:for_user => Factory(:user), :read_list => [@discussion2.id], :per_page => 1, :page => 2)
        assert_equal [@discussion, @conversation, @discussion2], Discussion.with_new_comments(:for_user => Factory(:user), :since => 1.day.ago)
      end
      
      should "find discussions #with_new_comments without a user" do
        assert_equal [@discussion, @conversation, @discussion2], Discussion.with_new_comments
        assert_equal [@discussion], Discussion.with_new_comments(:per_page => 1)
        assert_equal [@discussion, @conversation], Discussion.with_new_comments(:per_page => 2)
        assert_equal [@conversation], Discussion.with_new_comments(:per_page => 1, :page => 2)
        assert_equal [@discussion, @conversation], Discussion.with_new_comments(:since => 40.minutes.ago)
        assert_equal [@discussion, @conversation], Discussion.with_new_comments(:since => 40.minutes.ago, :by_user => true)
        assert_equal [@conversation], Discussion.with_new_comments(:since => 40.minutes.ago, :read_list => [@discussion.id])
      end
    end
    
    context "being conveniently introspective" do
      setup do
        board_discussions_in Board.science, 1
        @b_discussion = Board.science.discussions.first
        
        @live_collection = Factory :live_collection
        build_focus_for @live_collection
        @lc_discussion = @live_collection.discussions.first
        
        @collection = collection_for(@asset)
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
    
    context "serializing #to_embedded_hash" do
      setup do
        @hash = @discussion.to_embedded_hash
      end
      
      should "have values set correctly" do
        assert @hash.is_a?(Hash)
        assert_equal @discussion.number_of_comments, @hash['comments'].length
        
        @discussion.comments.each do |comment|
          assert_contains @hash['comments'], comment.to_embedded_hash
        end
        
        @hash.delete 'comments'
        assert_equal @discussion.to_mongo, @hash
      end
    end
  end
end
