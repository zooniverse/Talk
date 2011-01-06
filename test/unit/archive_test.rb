require 'test_helper'

class ArchiveTest < ActiveSupport::TestCase
  context "An Archive" do
    should_include_modules 'MongoMapper::Document'
    should_have_keys :kind, :original_id, :zooniverse_id, :user_id, :destroying_user_id,
                     :original_document, :created_at, :updated_at
  end
end
