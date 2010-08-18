module Taggable
  
  module ClassMethods
    def rank (tags)
      sorted =tags.sort { |a,b| a[1] <=> b[1]}
      high = sorted.last[1]
      low  = sorted.first[1]
      spread= high-low 
      no =8
      gap = (spread*1.0)/(no*1.0)
      result={}
      sorted.each do |a|
        tag= a[0]
        score=a[1]
        bin = ((score-low)/gap).floor
        result[tag]=bin
      end
    return result
    end
    
  end
  
end