require 'test_helper'

class RevisionTest < ActiveSupport::TestCase
  context "A Revision" do
    should_include_modules 'MongoMapper::Document'
    should_have_keys :original_id, :author_id, :revising_user_id, :body, :created_at, :updated_at
  end
end
