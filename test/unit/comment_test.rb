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
      
      @user1 = Factory :user
      @parent = Comment.new(:body=>"baskfojsdj", :author => @user1, :discussion => @discussion)
      
      @user2 = Factory :user
      @comment = Comment.new(:body=>"sdfsdfggsd", :author => @user2, :response_to => @parent, :discussion => @discussion)

      @user1.save
      @user2.save
      @comment.save
      @parent.save
      @discussion.save 
    end

    context "when scoring twice" do
      setup do
        @comment.cast_vote_by(@user1)
        @comment.reload
        @no_votes_before = @comment.upvotes.count
        @comment.cast_vote_by(@user1)
        @comment.reload
      end
      
      should "should only score once " do
        assert_equal @no_votes_before, @comment.upvotes.count
      end
    end
    

    context "when voting" do 
      setup do
         @comment.cast_vote_by @user1
         @comment.reload
      end
      
      should "should add vote" do
         assert @comment.upvotes.include?(@user1.id)
      end
    end
  end
end