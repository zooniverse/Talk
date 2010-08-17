require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  context "Single Comment" do
    setup do 
      @discussion = Factory :discussion
      @discussion.save

      @user1 = Factory :user
      @comment = Comment.new({:body=>"baskfojsdj"})
      # @parent = Factory :comment
     
      @discussion.comments<< @comment

      @user1.save
      @comment.save
      @discussion.save
    end
    
    should "have keys" do
      [ :discussion_id, :tags, :assets].each do |key|
        assert @comment.respond_to?(key)
      end
    end
      
    should "create associations" do
      assert @comment.associations.keys.include?("author")
      assert @comment.associations.keys.include?("discussion")
    end
    
    
  end
  
  context "Two Comments" do
    setup do
      @discussion = Factory :discussion
      @discussion.save
      
      @user1 = Factory :user
      @parent = Comment.new({:body=>"baskfojsdj"})
      # @parent = Factory :comment
      @user1.comments << @parent 
      @discussion.comments<< @parent
      
      @user2 = Factory :user
      # @comment = Factory :comment
      @comment = Comment.new({:body=>"sdfsdfggsd"})
      @user2.comments << @comment 
      @discussion.comments<< @comment
      @comment.response_to = @parent
      
      @user1.save
      @user2.save
      @comment.save
      @parent.save
      @discussion.save
      
    end
    
    should "Only score once" do
      no_votes_before = @comment.upvotes.count
      @comment.cast_vote_by(@user2)
      @comment.reload
      assert  no_votes_before == @comment.upvotes.count
    end
    
    should "Reject Scorring on own comment" do
      assert !@comment.cast_vote_by(@user2)
    end
  
    should "add vote" do
      @comment.cast_vote_by @user1
      @comment.reload
      assert @comment.upvotes.include?(@user1.id)
    end
  end
  
end