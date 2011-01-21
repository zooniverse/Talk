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
    MongoMapper.database.collections.reject{ |c| c.name == 'system.indexes' }.each do |collection|
      collection.remove
    end
    
    Board.create(:title => "science", :description => "awesome")
    Board.create(:title => "help", :description => "awesome")
    Board.create(:title => "chat", :description => "awesome")
  end
  
  def assert_not(assertion)
    assert !assertion
  end
  
  def standard_cas_login(user = nil)
    @user = user ||= Factory(:user)
    @request.session[:cas_user] = @user.name
    @request.session[:cas_extra_attributes] = {}
    @request.session[:cas_extra_attributes]['id'] = @user.zooniverse_user_id
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
    CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(true)
  end
  
  def admin_cas_login
    @user = Factory :user, :admin => true
    standard_cas_login(@user)
  end
  
  def moderator_cas_login
    @user = Factory :user, :moderator => true
    standard_cas_login(@user)
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
    [@focus1, @focus2, @focus3].each{ |f| f.conversation.focus.reload }
    
    @discussion = focus.discussions.first
    @conversation = focus.conversation
  end
  
  def build_discussions_for(focus)
    user = Factory(:user)
    discussion = Discussion.new :subject => "Monkey is an OIII emission"
    discussion.started_by_id = user.id
    
    focus.discussions << discussion
    focus.save
    discussion.reload
    
    @comment1 = Comment.new :body => "blah #tag1 blah #tag2 blah #{focus.zooniverse_id} is awesome"
    @comment1.author = user
    @comment2 = Comment.new :body => "blah #tag2 blah #tag4 blah #{focus.zooniverse_id} is awesome"
    @comment2.author = Factory :user
    @comment3 = Comment.new :body => "blah #tag2 blah #tag4 blah #{focus.zooniverse_id} is awesome"
    @comment3.author = Factory :user
    
    [@comment1, @comment2, @comment3].each do |comment|
      discussion.comments << comment
    end
    
    discussion.reload
    discussion.save
    focus.reload
    focus.save
  end
  
  def collection_for(asset)
    @collection = Collection.new :name => "Collection", :asset_ids => [asset.id]
    @collection.user = Factory :user
    @collection.save
    @collection
  end
  
  def build_collection(assets = 5)
    collection = Collection.new :name => "Collection"
    collection.user = Factory :user
    collection.save
    
    assets.times{ collection.assets << Factory(:asset) }
    collection
  end
  
  def build_live_collection(assets = 5)
    collection = LiveCollection.new :name => "LiveCollection"
    collection.user = Factory :user
    collection.tags = ['tag1']
    collection.save
    
    assets.times{ Factory(:asset, :tags => ['tag1']) }
    collection
  end
  
  def conversation_for(focus)
    conversation = focus.conversation
    comment1 = Comment.new :body => "blah #tag1 blah #tag2 blah #{focus.zooniverse_id} is awesome"
    comment1.author = Factory :user
    
    conversation.comments << comment1
    conversation.reload
    conversation.save
    focus.reload
    focus.save
  end
  
  def board_discussions_in(board, limit=8)
    1.upto(limit) do |i|
      discussion = Discussion.new :subject => "Topic ##{i}"
      discussion.started_by_id = Factory(:user).id
      discussion.focus_type = "Board"
      discussion.focus_id = board.id
      
      board.discussion_ids << discussion.id
      
      comment1 = Comment.new :body => "blah #tag1 blah #tag2 blah"
      comment1.author = discussion.started_by
      
      comment2 = Comment.new :body => "blah #tag2 blah #tag4 blah"
      comment2.author = Factory :user
      
      discussion.comments << comment1
      discussion.comments << comment2
      discussion.save
      board.save
    end
    
    board
  end
end
