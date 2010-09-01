ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module Shoulda
  class Context
    def should_have_keys(*keys)
      klass = described_type
      
      keys.each do |key|
        should "have key #{key}" do
          assert klass.key?(key), "#{klass.name} does not have key #{key}"
        end
      end
    end
    
    def should_associate(*klasses)
      klass = described_type
      
      klasses.each do |other_klass|
        should "have associated #{other_klass}" do
          assert_contains klass.associations.keys, other_klass.to_s
        end
      end
    end
    
    def should_include_modules(*modules)
      _should_include(*modules) do |klass, mod|
        should "include module #{mod}" do
          assert klass.include?(mod), "#{klass.name} does not include module #{mod}"
        end
      end
    end
    
    def should_include_plugins(*plugins)
      _should_include(*plugins) do |klass, plugin|
        should "include plugin #{plugin}" do
          assert klass.plugins.include?(plugin), "#{klass.name} does not include plugin #{plugin}"
        end
      end
    end
    
    private
    def _should_include(*args, &block)
      klass = described_type
      
      args.each do |arg|
        arg = arg.to_s.camelize.constantize
        yield(klass, arg)
      end
    end
  end
end

class ActiveSupport::TestCase
  def setup
    # To empty the xapian db
    Comment.destroy_all
    Asset.destroy_all
    Discussion.destroy_all
    
    MongoMapper.database.collections.reject{ |c| c.name == 'system.indexes' }.each do |collection|
      collection.remove
    end
    
    Board.create(:title => "science", :description => "awesome")
    Board.create(:title => "help", :description => "awesome")
    Board.create(:title => "chat", :description => "awesome")
  end
  
  def standard_cas_login(user = nil)
    @user = user ||= Factory(:user)
    @request.session[:cas_user] = @user.name
    @request.session[:cas_extra_attributes] = {}
    @request.session[:cas_extra_attributes]['id'] = @user.zooniverse_user_id
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
  end
  
  def admin_cas_login
    @user = Factory :user, :admin => true
    @request.session[:cas_user] = @user.name
    @request.session[:cas_extra_attributes] = {}
    @request.session[:cas_extra_attributes]['id'] = @user.zooniverse_user_id
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
  end
  
  def moderator_cas_login
    @user = Factory :user, :moderator => true
    @request.session[:cas_user] = @user.name
    @request.session[:cas_extra_attributes] = {}
    @request.session[:cas_extra_attributes]['id'] = @user.zooniverse_user_id
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
  end
  
  def clear_cas
    @user = Factory :user
    @request.session[:cas_user] = {}
    @request.session[:cas_extra_attributes] = {}
  end
  
  def build_focus_for(focus)
    @focus1 = focus
    klass = focus.class.name.underscore
    
    2.upto(3) do |i|
      f = instance_variable_set("@#{klass + i.to_s}", Factory(klass.to_sym))
      instance_variable_set("@focus#{i}", f)
      f.save
    end
    
    build_discussions_for @focus2
    build_discussions_for @focus3
    build_discussions_for @focus1
    
    @discussion = focus.discussions.first
    @conversation = focus.conversation
    @discussion.comments.each.with_index{ |c, i| instance_variable_set "@comment#{i + 1}", c }
  end
  
  def build_discussions_for(focus)
    user = Factory(:user)
    discussion = Discussion.new(:subject => "Monkey is an OIII emission", :started_by_id => user.id)
    focus.discussions << discussion
    focus.save
    discussion.reload
    
    comment1 = Comment.new(:body => "blah #tag1 blah #tag2 blah #{focus.zooniverse_id} is awesome", :author => user)
    comment2 = Comment.new(:body => "blah #tag2 blah #tag4 blah #{focus.zooniverse_id} is awesome", :author => Factory(:user))
    comment3 = Comment.new(:body => "blah #tag2 blah #tag4 blah #{focus.zooniverse_id} is awesome", :author => Factory(:user))
    
    [comment1, comment2, comment3].each do |comment|
      discussion.comments << comment
    end
    
    discussion.reload
    discussion.save
    focus.reload
    focus.save
  end
  
  def collection_for(asset)
    @collection = Collection.create(:name => "Collection", :asset_ids => [asset.id], :user => Factory(:user))
  end
  
  def build_collection(assets = 5)
    collection = Collection.create(:name => "Collection", :user => Factory(:user))
    assets.times{ collection.assets << Factory(:asset) }
    collection
  end
  
  def build_live_collection(assets = 5)
    collection = LiveCollection.create(:name => "LiveCollection", :user => Factory(:user), :tags => ['tag1'])
    assets.times{ Factory(:asset, :taggings => { 'tag1' => 1 }) }
    collection
  end
  
  def conversation_for(focus)
    conversation = focus.conversation
    comment1 = Comment.new(:body => "blah #tag1 blah #tag2 blah #{focus.zooniverse_id} is awesome", :author => Factory(:user))
    conversation.comments << comment1
    conversation.reload
    conversation.save
    focus.reload
    focus.save
  end
  
  def board_discussions_in(board, limit=8)
    1.upto(limit) do |i|
      discussion = Discussion.new(:subject => "Topic ##{i}", :started_by_id => Factory(:user).id, :focus_type => "Board", :focus_id => board.id)
      board.discussion_ids << discussion.id
      
      discussion.comments << Comment.new(:body => "blah #tag1 blah #tag2 blah", :author => Factory(:user))
      discussion.comments << Comment.new(:body => "blah #tag2 blah #tag4 blah", :author => Factory(:user))
      discussion.save
      board.save
    end
    
    board
  end
end
