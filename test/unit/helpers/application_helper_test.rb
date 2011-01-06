require 'test_helper'
require 'application_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper
  
  context "Application Helper" do
    setup do
      @user = Factory :user
    end

    should "return correct css class for a standard user" do
      assert_equal name_class_for(@user), "name"
    end
  end
  
  context "Application Helper" do
    setup do
      @user = Factory :user, :admin => true
    end

    should "return correct css class for admin" do
      assert_equal name_class_for(@user), "name admin"
    end
  end
  
  context "Application Helper" do
    setup do
      @user = Factory :user, :scientist => true
    end

    should "return correct css class for science team" do
      assert_equal name_class_for(@user), "name scientist"
    end
  end
  
  context "Application Helper" do
    setup do
      @user = Factory :user, :moderator => true
    end

    should "return correct css class for a moderator" do
      assert_equal name_class_for(@user), "name moderator"
    end
  end
end