require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  context "A message" do 
    
    setup do
      @message = Factory :message
    end
    
    should "have keys" do
      [:title, :body, :sender_id,:recipient_id].each do |key|
        assert @message.respond_to?(key)
      end
    end
    
    should "have correct associations" do
      assert @message.associations.keys.include?("sender")
      assert @message.associations.keys.include?("recipient")
    end
  end
end