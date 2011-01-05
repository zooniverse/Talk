module CASClient
  module Frameworks
    module Rails
      class Filter
        class << self
          alias_method :old_filter, :filter
          
          def filter(controller)
            user_before = controller.send(:current_zooniverse_user)
            filter_response = old_filter(controller)
            user_after = controller.send(:current_zooniverse_user)
            
            if user_before.nil? && user_after
              user_after.update_login!
            end
            
            filter_response
          end
        end
      end
    end
  end
end
