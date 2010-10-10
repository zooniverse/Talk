class Tag
  include MongoMapper::Document
  
  key :name, String
  key :count, Integer, :default => 0
  
  # Finds the trending tags for a focus
  def self.for_focus(focus, limit = 10)
    Tagging.limit(limit).sort(:count.desc).all(:focus_id => focus.id)
  end
  
  # Finds the trending tags for a discussion
  def self.for_discussion(discussion, limit = 10)
    Tagging.limit(limit).sort(:count.desc).all(:discussion_ids => discussion.id)
  end
  
  # Gets the top most used tags
  def self.trending(limit = 10)
    Tag.sort(:count.desc).limit(limit).all.collect{ |tag| tag.name }
  end
  
  # Normalizes and interpolates trending_tags onto a range
  #  Tag.rank_tags :from => 0, :to => 8
  def self.rank_tags(*args)
    opts = { :limit => 10, :from => 0, :to => 10 }.update(args.extract_options!)
    new_range = opts[:to] - opts[:from]
    
    trended = {}
    Tag.sort(:count.desc).limit(opts[:limit]).all.each{ |tag| trended[tag.name] = tag.count }
    return {} if trended.empty?

    min, max = trended.values.minmax
    old_range = [0.1, max - min.to_f].max
    
    trended.each_pair do |tag, count|
      trended[tag] = (opts[:from] + ((count - min) / old_range) * new_range).round
    end
  end
end
