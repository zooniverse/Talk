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
  
  #Gets the top trending tags (placeholder just now)
  def self.trending_tags(no=1)
     {"njdfk"=>2,"fmsfsd"=>4,"addd"=>10,"cccda"=>1,"dsljnfne"=>99,"nfjdsfj"=>33,"djbf"=>3,"nfsdjf"=>8,"fff"=>20,"fffff"=>55}
  end
end
