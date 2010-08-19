module Taggable
  def self.included(base)
     base.extend ClassMethods
     base.send :include, InstanceMethods
  end
  
  module ClassMethods
    def rank_tags (tags, no=8)
      result={}
      unless tags.empty?  
        sorted = tags.sort { |a,b| a[1] <=> b[1]}
        high = sorted.last[1]
        low  = sorted.first[1]
        spread = high-low 
        gap = (spread*1.0)/(no*1.0)
        sorted.each do |a|
          tag = a[0]
          score = a[1]
          bin = ((score-low)/gap).floor
          result[tag] = bin
        end
      end
    return result
    end
    
  end
  
  module InstanceMethods
    
    def rank_tags (no=8)
        result = {}
        
        unless self.tags.empty?  
          tags=self.tags
          sorted = tags.sort { |a,b| a[1] <=> b[1]}
          high = sorted.last[1]
          low  = sorted.first[1]
          spread = high-low 
          gap = (spread*1.0)/(no*1.0)
          sorted.each do |a|
            tag = a[0]
            score = a[1]
            bin = ((score-low)/gap).floor
            result[tag] = bin
          end
        end
        result 
      end
        
  
  end
  
end