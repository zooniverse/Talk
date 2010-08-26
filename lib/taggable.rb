module Taggable
  def self.included(base)
    base.class_eval do
      key :taggings, Hash, :default => Hash.new(0)
    end
    
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def tags
      self.taggings.sort{ |a, b| b[1] <=> a[1] }.collect{ |t| t.first }
    end
  end
end