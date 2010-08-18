# A Comment on a Discussion by a User
class Comment
  include MongoMapper::Document
  include ZooniverseId
  include Taggable
  
  
  key :discussion_id, ObjectId, :required => true
  key :author_id, ObjectId, :required => true
  key :upvotes, Array
  key :body, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, whether these make their way up to the discussion level is TBD
  timestamps!
  
  belongs_to :discussion
  belongs_to :author, :class_name => "User"
  one :response_to, :class_name => "Comment", :foreign_key => "response_to_id"
  
  # Atomic operation to let a User vote for a Comment
  def cast_vote_by(user)
    return if author.id == user.id
    Comment.collection.update({ '_id' => self.id }, {'$addToSet' => { 'upvotes' => user.id } })
  end
  
  def self.most_recent(no=10)
    Comment.limit(no).sort(['created_at', -1]).all(:created_at.gt => Time.now - 1.day)
  end
  
  # Finds comments mentioning an asset
  def self.mentioning(asset, *args)
    opts = { :limit => 10, :order => ['created_at', -1] }
    opts = opts.update(args.first) unless args.first.nil?
    Comment.limit(opts[:limit]).sort(opts[:order]).all(:assets => asset.zooniverse_id)
  end
  
  # Gets the top most used tags
  def self.trending_tags
     map = <<-MAP
     function() {
       this.tags.forEach( function(tag) {
         emit(tag, { count: 1 });
       });
     }
     MAP

     reduce = <<-REDUCE
     function(key, values) {
       var total = 0;
       for(var i = 0; i < values.length; i++) {
         total += values[i].count;
       }

       return { count: total };
     }
     REDUCE
     
     tags = Comment.collection.map_reduce(map, reduce).find().sort(['value.count', -1]).limit(10).to_a
     
     collected = {}
     tags.each{ |tag| collected[tag['_id']] = tag['value']['count'].to_i }
     collected
  end
end
