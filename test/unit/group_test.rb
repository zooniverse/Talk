require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  context "A Group" do
    setup do
      build_group
      build_focus_for @group
    end
    
    should_associate :assets
    should_include_modules :focus, 'MongoMapper::Document'
    should_have_keys :zooniverse_id, :tags, :conversation_id, :discussion_ids, :created_at, :updated_at
    
    should "find assets" do
      assert_equal @group.assets.length, 5
    end
    
    should "know its #discussion_path" do
      base = "/groups/#{ @group.zooniverse_id }/discussions/#{ @discussion.zooniverse_id }"
      assert_equal base, @group.discussion_path(@discussion)
      assert_equal "#{ base }?page=10", @group.discussion_path(@discussion, :page => 10)
      assert_equal "#{ base }?page=10&per_page=10", @group.discussion_path(@discussion, :page => 10, :per_page => 10)
    end
    
    should "know its #conversation_path" do
      base = "/groups/#{ @group.zooniverse_id }"
      assert_equal base, @group.conversation_path(@conversation)
      assert_equal "#{ base }?page=10", @group.conversation_path(@conversation, :page => 10)
      assert_equal "#{ base }?page=10&per_page=10", @group.conversation_path(@conversation, :page => 10, :per_page => 10)
    end
  end
end
