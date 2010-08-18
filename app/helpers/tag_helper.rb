module TagHelper

  def rank (tags)
   sorted =tags.sort { |a,b| a[1] <=> b[1]}
   high = sorted.last[1]
   low  = sorted.first[1]
   spread= high-low 
   no =8
   gap = (spread*1.0)/(no*1.0)
   sorted.insert({}) {|h,v| h[v[0]]= ((v[1]-low)/gap).floor}
  end

end