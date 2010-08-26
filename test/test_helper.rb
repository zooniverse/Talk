ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def setup
    Comment.destroy_all # To empty the xapian db
    
    MongoMapper.database.collections.reject{ |c| c.name == 'system.indexes' }.each do |collection|
      collection.remove
    end
    
    Board.create(:title => "science", :description => "awesome")
    Board.create(:title => "help", :description => "awesome")
    Board.create(:title => "chat", :description => "awesome")
  end
  
  def standard_cas_login
    @user = Factory :user
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
    discussion = Discussion.new(:subject => "Monkey is an OIII emission", :started_by_id => Factory(:user).id)
    focus.discussions << discussion
    focus.save
    discussion.reload
    
    comment1 = Comment.new(:body => "blah", :author => Factory(:user), :tags => ['tag1', 'tag2'], :mentions => focus.zooniverse_id)
    comment2 = Comment.new(:body => "blah", :author => Factory(:user), :tags => ['tag2', 'tag4'], :mentions => focus.zooniverse_id)
    comment3 = Comment.new(:body => "blah", :author => Factory(:user), :tags => ['tag2', 'tag4'], :mentions => focus.zooniverse_id)
    
    [comment1, comment2, comment3].each do |comment|
      discussion.comments << comment
    end
    
    discussion.reload
    discussion.save
    
    focus.reload
  end
end
