require 'test_helper'

class EventTest < ActiveSupport::TestCase
  context "An Event" do
    setup do
    end
    
    should_have_keys :title, :details, :state, :user_id, :created_at, :updated_at
    should_associate :user, :eventable
    should_include_modules 'MongoMapper::Document'
  end
  
end
