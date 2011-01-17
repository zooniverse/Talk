require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A Comment" do
    setup do 
      @asset = Factory :asset
      build_focus_for @asset
      @comment = @comment1
    end
    
    should_have_keys :discussion_id, :response_to_id, :author_id, :upvotes, :edit_count, 
                     :body, :_body, :tags, :mentions, :created_at, :updated_at, :focus_id,
                     :focus_type, :focus_base_type
    should_associate :author, :discussion, :events
    should_include_modules 'MongoMapper::Document'
    
    context "in #response_to another" do
      setup do
        @comment2.response_to = @comment
      end
      
      should "know it is a #response?" do
        assert @comment2.response?
        assert !@comment.response?
      end
      
      should "store the #response_to_id" do
        assert_equal @comment.id, @comment2.response_to_id
      end
      
      should "find the #response_to comment" do
        assert_equal @comment, @comment2.response_to
      end
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
    
    should "find #recent" do
      assert_contains Comment.recent, @comment1
      assert_contains Comment.recent, @comment2
      assert_contains Comment.recent, @comment3
    end
    
    should "find #mentioning" do
      assert_same_elements [@comment1, @comment2, @comment3], Comment.mentioning(@asset, :limit => 3)
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
    
    should "#create_tags" do
      assert_same_elements ['tag2', 'tag4', 'tag1'], @asset.tags
      assert_equal ['tag2', 'tag4', 'tag1'], Tag.for_focus(@asset).collect{ |t| t.name }
      
      [['tag1', 1], ['tag2', 3], ['tag4', 2]].each do |tag, count|
        assert Tagging.first(:name => tag, :focus_id => @asset.id, :focus_type => "Asset", :count => count)
      end
    end
    
    context "parsing tags and mentions" do
      setup do
        comment = @comment1.to_mongo.update({ "body" => "blah #Mixed #CASE #tAgS #tag1 blah #tag2 blah #{ @asset.zooniverse_id } is awesome" })
        @comment1 = Comment.create(comment)
      end
      
      should "#parse_body for tags and mentions" do
        assert_same_elements %w(mixed case tags tag1 tag2 ), @comment1.tags
        assert_same_elements ['tag2', 'tag4'], @comment2.tags
        assert_same_elements ['tag2', 'tag4'], @comment3.tags
        
        assert_equal [@asset.zooniverse_id], @comment1.mentions
        assert_equal [@asset.zooniverse_id], @comment2.mentions
        assert_equal [@asset.zooniverse_id], @comment3.mentions
      end
      
      should "match tags" do
        bodies = ['#tag1' '#tag-1' '#tag_1' '#t' '#t@g1' '#tag 1']
        tags = ['tag1', 'tag-1', 'tag_1', nil, nil, 'tag']
        
        bodies.zip(tags).each do |body, tag|
          c = Comment.new(:body => body)
          c.parse_body
          assert_equal tag, c.tags.first
        end
      end
      
      should "match mentions" do
        assert_equal "AMZ10000aa", "a AMZ10000aa ".scan(Comment::MENTION).flatten.first
        assert_equal nil, "a amz10000aa ".scan(Comment::MENTION).flatten.first
        assert_equal nil, "a amz10000a ".scan(Comment::MENTION).flatten.first
      end
    end
    
    context "being searched" do
      should "paginate" do
        search = Comment.search "blah", :per_page => 2
        assert_equal 5, search.total_pages
        assert_equal 9, search.total_entries
      end
      
      should "match on body terms" do
        assert_equal [@comment], Comment.search("#tag1 #{@asset.zooniverse_id}")
        assert_same_elements [@comment1, @comment2, @comment3], Comment.search(@asset.zooniverse_id)
      end
      
      should "match on other fields" do
        assert_same_elements [@comment1, @comment2, @comment3], Comment.search(@asset.zooniverse_id, :field => :mentions)
      end
      
      should "match by focus_type" do
        assert_same_elements [@comment1, @comment2, @comment3], Comment.search(@asset.zooniverse_id, :focus_type => "Asset")
        [@comment1, @comment2, @comment3].each do |comment|
          assert_contains Comment.search("blah", :focus_type => "Asset"), comment
        end
      end
    end
    
    context "being modified" do
      setup do
        @original1 = @comment1.body
        @comment1.update_attributes({ :body => @comment1.body + " #new_tag" }, :revising_user => @comment1.author)
        @comment1.reload
        @revision1 = Revision.first(:original_id => @comment1.id)
        
        @moderator = Factory :user, :moderator => true
        @original2 = @comment2.body
        @comment2.update_attributes({ :body => @comment2.body + " #tag1" }, :revising_user => @moderator)
        @comment2.reload
        @revision2 = Revision.first(:original_id => @comment2.id)
        
        @original3 = @comment3.body
        @comment3.update_attributes({ :body => " #tag3 #tag2" }, :revising_user => @comment3.author)
        @comment3.reload
        @revision3 = Revision.first(:original_id => @comment3.id)
        
        @asset.reload
        
        @new_tagging = Tagging.first(:name => 'new_tag', :focus_id => @comment1.focus_id)
        @tag1_tagging = Tagging.first(:name => 'tag1', :focus_id => @comment1.focus_id)
        @tag2_tagging = Tagging.first(:name => 'tag2', :focus_id => @comment1.focus_id)
        @tag3_tagging = Tagging.first(:name => 'tag3', :focus_id => @comment1.focus_id)
        @tag4_tagging = Tagging.first(:name => 'tag4', :focus_id => @comment1.focus_id)
        
        @new_tag = Tag.find_by_name "new_tag"
        @tag1 = Tag.find_by_name "tag1"
        @tag2 = Tag.find_by_name "tag2"
        @tag3 = Tag.find_by_name "tag3"
        @tag4 = Tag.find_by_name "tag4"
      end
      
      should "update edit_counts" do
        assert_equal 1, @comment1.edit_count
        assert_equal 1, @comment2.edit_count
        assert_equal 1, @comment3.edit_count
      end
      
      should "#create_revision_as the updating user" do
        assert_equal @original1, @revision1.body
        assert_equal @comment1.author_id, @revision1.author_id
        assert_equal @comment1.author_id, @revision1.revising_user_id
        
        assert_equal @original2, @revision2.body
        assert_equal @comment2.author_id, @revision2.author_id
        assert_equal @moderator.id, @revision2.revising_user_id
        
        assert_equal @original3, @revision3.body
        assert_equal @comment3.author_id, @revision3.author_id
        assert_equal @comment3.author_id, @revision3.revising_user_id
      end
      
      should "update comment tags" do
        assert_same_elements %w(tag1 tag2 new_tag), @comment1.tags
        assert_same_elements %w(tag1 tag2 tag4), @comment2.tags
        assert_same_elements %w(tag2 tag3), @comment3.tags
      end
      
      should "update taggings" do
        assert_same_elements %w(tag1 tag2 tag3 tag4 new_tag), Tag.for_discussion(@comment1.discussion).collect{ |t| t.name }
        assert_same_elements %w(tag1 tag2 tag3 tag4 new_tag), Tag.for_focus(@comment1.focus).collect{ |t| t.name }
        
        assert_equal 1, @new_tagging.count
        assert_same_elements [@comment1.id], @new_tagging.comment_ids
        assert_same_elements [@comment1.discussion.id], @new_tagging.discussion_ids
        
        assert_equal 2, @tag1_tagging.count
        assert_same_elements [@comment1.id, @comment2.id], @tag1_tagging.comment_ids
        assert_same_elements [@comment1.discussion.id], @tag1_tagging.discussion_ids
        
        assert_equal 3, @tag2_tagging.count
        assert_same_elements [@comment1.id, @comment2.id, @comment3.id], @tag2_tagging.comment_ids
        assert_same_elements [@comment1.discussion.id], @tag2_tagging.discussion_ids
        
        assert_equal 1, @tag3_tagging.count
        assert_same_elements [@comment3.id], @tag3_tagging.comment_ids
        assert_same_elements [@comment3.discussion.id], @tag3_tagging.discussion_ids
        
        assert_equal 1, @tag4_tagging.count
        assert_same_elements [@comment2.id], @tag4_tagging.comment_ids
        assert_same_elements [@comment2.discussion.id], @tag4_tagging.discussion_ids
      end
      
      should "update tags" do
        assert_equal 1, @new_tag.count
        assert_equal 4, @tag1.count
        assert_equal 9, @tag2.count
        assert_equal 1, @tag3.count
        assert_equal 5, @tag4.count
      end
      
      should "update asset tags" do
        assert_same_elements %w(tag1 tag2 tag3 tag4 new_tag), @asset.tags
      end
      
      context "by removing tags" do
        setup do
          conversation_for @asset
          @asset.reload
          @comment4 = @asset.conversation.comments.first
          
          @comment1.body = "gone!"
          @comment1.save
          @comment1.reload
          
          @comment2.body = "#tag4"
          @comment2.save
          @comment2.reload
          
          @comment3.body = "#tag2"
          @comment3.save
          @comment3.reload
          
          @asset.reload
          
          @tag1_tagging.reload
          @tag2_tagging.reload
          @tag4_tagging.reload
          
          @tag1.reload
          @tag2.reload
          @tag4.reload
        end
        
        should "update comment tags" do
          assert_same_elements [], @comment1.tags
          assert_same_elements ['tag4'], @comment2.tags
          assert_same_elements ['tag2'], @comment3.tags
        end
        
        should "update taggings" do
          assert_same_elements %w(tag2 tag4), Tag.for_discussion(@comment1.discussion).collect{ |t| t.name }
          assert_same_elements %w(tag1 tag2 tag4), Tag.for_focus(@comment1.focus).collect{ |t| t.name }
          
          assert_raise(MongoMapper::DocumentNotFound) { @new_tagging.reload }
          
          assert_equal 1, @tag1_tagging.count
          assert_same_elements [@comment4.id], @tag1_tagging.comment_ids
          assert_same_elements [@comment4.discussion.id], @tag1_tagging.discussion_ids
          
          assert_equal 2, @tag2_tagging.count
          assert_same_elements [@comment3.id, @comment4.id], @tag2_tagging.comment_ids
          assert_same_elements [@comment3.discussion.id, @comment4.discussion.id], @tag2_tagging.discussion_ids
          
          assert_raise(MongoMapper::DocumentNotFound) { @tag3_tagging.reload }
          
          assert_equal 1, @tag4_tagging.count
          assert_same_elements [@comment2.id], @tag4_tagging.comment_ids
          assert_same_elements [@comment2.discussion.id], @tag4_tagging.discussion_ids
        end
        
        should "update tags" do
          assert_raise(MongoMapper::DocumentNotFound) { @new_tag.reload }
          assert_equal 3, @tag1.count
          assert_equal 8, @tag2.count
          assert_raise(MongoMapper::DocumentNotFound) { @tag3.reload }
          assert_equal 5, @tag4.count
        end
        
        should "update asset_tags" do
          assert_same_elements %w(tag1 tag2 tag4), @asset.tags
        end
      end
      
      context "by destroying" do
        setup do
          conversation_for @asset
          @comment4 = @asset.conversation.comments.first
          
          @comment3.cast_vote_by(Factory(:user))
          @discussion.reload
          
          @comment1.destroy
          @comment2.archive_and_destroy_as @comment2.author
          @archive2 = Archive.first(:kind => "Comment", :original_id => @comment2.id)
          
          @asset.reload
          
          @tag1_tagging.reload
          @tag2_tagging.reload
          @tag3_tagging.reload
          
          @tag1.reload
          @tag2.reload
          @tag3.reload
          @tag4.reload
        end
        
        should "create archive and destroy comment" do
          assert_raise(MongoMapper::DocumentNotFound) { @comment2.reload }
          assert_equal @comment2.body, @archive2.original_document['body']
          assert_equal @comment2.edit_count, @archive2.original_document['revisions'].length
          assert_equal "blah #tag2 blah #tag4 blah #{ @comment2.focus.zooniverse_id } is awesome", @archive2.original_document['revisions'].first['body']
          assert_equal 1, Archive.count
        end
        
        should "update taggings" do
          assert_same_elements %w(tag2 tag3), Tag.for_discussion(@comment1.discussion).collect{ |t| t.name }
          assert_same_elements %w(tag1 tag2 tag3), Tag.for_focus(@comment1.focus).collect{ |t| t.name }
          
          assert_raise(MongoMapper::DocumentNotFound) { @new_tagging.reload }
          
          assert_equal 1, @tag1_tagging.count
          assert_same_elements [@comment4.id], @tag1_tagging.comment_ids
          assert_same_elements [@comment4.discussion.id], @tag1_tagging.discussion_ids
          
          assert_equal 2, @tag2_tagging.count
          assert_same_elements [@comment3.id, @comment4.id], @tag2_tagging.comment_ids
          assert_same_elements [@comment3.discussion.id, @comment4.discussion.id], @tag2_tagging.discussion_ids
          
          assert_equal 1, @tag3_tagging.count
          assert_same_elements [@comment3.id], @tag3_tagging.comment_ids
          assert_same_elements [@comment3.discussion.id], @tag3_tagging.discussion_ids
          
          assert_raise(MongoMapper::DocumentNotFound) { @tag4_tagging.reload }
        end
        
        should "update tags" do
          assert_raise(MongoMapper::DocumentNotFound) { @new_tag.reload }
          assert_equal 3, @tag1.count
          assert_equal 8, @tag2.count
          assert_equal 1, @tag3.count
          assert_equal 4, @tag4.count
        end
        
        should "update discussion counts" do
          assert_equal 3, @discussion.number_of_comments
          assert_equal 3, @discussion.number_of_users
          assert_equal 7, @discussion.popularity
          
          @discussion.reload
          
          assert_equal 1, @discussion.number_of_comments
          assert_equal 1, @discussion.number_of_users
          assert_equal 3, @discussion.popularity
        end
      end
      
    end
  end
end
