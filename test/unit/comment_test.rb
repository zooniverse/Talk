require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  context "A Comment" do
    setup do 
      @asset = Factory :asset
      build_focus_for @asset
      @comment = @comment1
    end
    
    should "have keys" do
      [ :discussion_id, :tags, :mentions].each do |key|
        assert @comment.respond_to?(key)
      end
    end
      
    should "create associations" do
      assert @comment.associations.keys.include?("author")
      assert @comment.associations.keys.include?("discussion")
    end

    context "when upvoting" do
      setup do
        @user = Factory :user
        @comment.cast_vote_by(@user)
        @votes_before = @comment.reload.upvotes.count
        @comment.cast_vote_by(@user)
      end
      
      should "should add vote" do
        assert @comment.reload.upvotes.include?(@user.id)
      end
      
      should "should only score once " do
        assert_equal @votes_before, @comment.reload.upvotes.count
      end
    end
    
    should "find #most_recent" do
      assert Comment.most_recent(3).include? @comment1
      assert Comment.most_recent(3).include? @comment2
      assert Comment.most_recent(3).include? @comment3
    end
    
    should "find #mentioning" do
      assert Comment.mentioning(@asset, :limit => 3).include? @comment1
      assert Comment.mentioning(@asset, :limit => 3).include? @comment2
      assert Comment.mentioning(@asset, :limit => 3).include? @comment3
    end
    
    should "find #trending_tags" do
      assert_equal ['tag2', 'tag4', 'tag1'], Comment.trending_tags(3).keys
    end
    
    should "know the #focus_type" do
      assert_equal "Asset", @comment.focus_type
    end
    
    should "know the #focus_id" do
      assert_equal @asset.id, @comment.focus_id
    end
    
    should "know the #focus" do
      assert_equal @asset, @comment.focus
    end
  end
end