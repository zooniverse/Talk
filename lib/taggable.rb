module Taggable
  def self.included(base)
    base.class_eval do
      key :taggings, Hash, :default => Hash.new(0)
    end
    
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
    def rank_tags(tags, no=8)
      result = {}

      unless tags.empty?
        tags = tags
        sorted = tags.sort { |a, b| a[1] <=> b[1] }
        high = sorted.last[1]
        low  = sorted.first[1]
        spread = high - low
        gap = (spread * 1.0) / (no * 1.0)
        sorted.each do |a|
          tag = a[0]
          score = a[1]
          bin = ((score - low) / gap).floor
          result[tag] = bin
        end
      end

      result
    end
  end
  
  module InstanceMethods
    def tags
      self.taggings.sort{ |a, b| b[1] <=> a[1] }.collect{ |t| t.first }
    end
  end
end