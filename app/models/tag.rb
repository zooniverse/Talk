# A Keyword
class Tag
  include MongoMapper::Document
  
  key :name, String
  key :count, Integer, :default => 0
  
  # Selects the trending Tags for a Focus
  # @param focus The Focus to find Tags for
  # @param limit [Fixnum] The number of Tags to find
  def self.for_focus(focus, limit = 10)
    Tagging.limit(limit).sort(:count.desc).all(:focus_id => focus.id)
  end
  
  # Selects the trending Tags for a Discussion
  # @param discussion [Discussion] The discussion to find Tags for
  # @param limit [Fixnum] The number of Tags to find
  def self.for_discussion(discussion, limit = 10)
    Tagging.limit(limit).sort(:count.desc).all(:discussion_ids => discussion.id)
  end
  
  # Selects the most popular Tags
  # @option *args [Fixnum] :page (1) The page of Tags to find
  # @option *args [Fixnum] :per_page (10) The number of Tags per page
  def self.trending(*args)
    opts = { :page => 1, :per_page => 10 }.update(args.extract_options!)
    Tag.sort(:count.desc).paginate(opts).collect{ |tag| tag.name }
  end
  
  # Normalizes and interpolates trending Tags onto a range
  # @option *args [Fixnum] :limit (10) The number of Tags to find
  # @option *args [Fixnum] :from (0) The minimum score of the range
  # @option *args [Fixnum] :to (10) The maximum score of the range
  def self.rank_tags(*args)
    opts = { :limit => 10, :from => 0, :to => 10 }.update(args.extract_options!)
    new_range = opts[:to] - opts[:from]
    
    trended = {}
    Tag.sort(:count.desc).limit(opts[:limit]).all.each{ |tag| trended[tag.name] = tag.count }
    return {} if trended.empty?
    
    min, max = trended.values.minmax
    old_range = [0.1, Math.log(max) - Math.log(min)].max
    
    trended.each_pair do |tag, count|
      trended[tag] = (opts[:from] + (( Math.log(count) - Math.log(min) ) / old_range) * new_range).round
    end
  end
end
