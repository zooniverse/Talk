require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  context "A Discussion" do
    setup do
      @discussion = Discussion.new
    end
    
    should "have keys" do
      [:subject, :tags, :assets, :focus_id, :focus_type, :slug, :created_at, :updated_at].each do |key|
        assert @discussion.respond_to?(key)
      end
    end
  end
  
  context "A Discussion" do
    setup do
      @discussion = Factory :discussion
      @user = Factory :user
      @comment = Comment.new(:body => "Hell yeah, he's a great looking monkey", :author => @user)
      @discussion.comments << @comment
    end

    should "have correct associations" do
      assert @discussion.comments.include?(@comment)
      assert @discussion.associations.keys.include?("comments")
    end
  end
  
  context "When creating a new discussion" do
    setup do
      @discussion = Discussion.create(:subject => "Arfon's great discussion")
    end

    should "#set_slug correctly" do
      assert_equal @discussion.slug, "arfon-s-great-discussion"
    end
  end
end