def drop_indexes_on(model)
  model.collection.drop_indexes if model.count > 0
end

desc "Creates indexes on collections"
task :ensure_indexes => :environment do
  puts "Building indexes for Asset"
  drop_indexes_on(Asset)
  Asset.ensure_index [['zooniverse_id', 1]], :unique => true
  Asset.ensure_index [['tags', 1]]
  
  puts "Building indexes for Board"
  drop_indexes_on(Board)
  Board.ensure_index [['title', 1]]
  
  puts "Building indexes for Collection"
  drop_indexes_on(Collection)
  Collection.ensure_index [['zooniverse_id', 1]], :unique => true
  Collection.ensure_index [['user_id', 1], ['created_at', -1]]
  Collection.ensure_index [['asset_ids', 1]]
  Collection.ensure_index [['created_at', -1]]
  
  puts "Building indexes for Comment"
  drop_indexes_on(Comment)
  Comment.ensure_index [['response_to_id', 1]]
  Comment.ensure_index [['discussion_id', 1], ['created_at', -1]]
  Comment.ensure_index [['author_id', 1], ['created_at', -1]]
  Comment.ensure_index [['tags', 1]]
  Comment.ensure_index [['mentions', 1], ['created_at', -1]]
  Comment.ensure_index [['_body', 1], ['focus_type', 1], ['created_at', -1]]
  Comment.ensure_index [['created_at', -1]]
  
  puts "Building indexes for Discussion"
  drop_indexes_on(Discussion)
  Discussion.ensure_index [['zooniverse_id', 1]], :unique => true
  Discussion.ensure_index [['slug', 1]]
  Discussion.ensure_index [['focus_id', 1], ['created_at', -1]]
  Discussion.ensure_index [['focus_type', 1], ['created_at', -1]]
  Discussion.ensure_index [['featured', 1], ['created_at', -1]]
  Discussion.ensure_index [['created_at', -1]]
  Discussion.ensure_index [['focus_type', 1], ['updated_at', -1], ['number_of_comments', -1]]
  Discussion.ensure_index [['number_of_comments', -1]]
  
  puts "Building indexes for Event"
  drop_indexes_on(Event)
  Event.ensure_index [['state', 1], ['created_at', -1]]
  Event.ensure_index [['user_id', 1], ['created_at', -1]]
  
  puts "Building indexes for LiveCollection"
  drop_indexes_on(LiveCollection)
  LiveCollection.ensure_index [['zooniverse_id', 1]], :unique => true
  LiveCollection.ensure_index [['tags', 1], ['created_at', -1]]
  LiveCollection.ensure_index [['user_id', 1], ['created_at', -1]]
  
  puts "Building indexes for Message"
  drop_indexes_on(Message)
  Message.ensure_index [['sender_id', 1], ['recipient_id', 1], ['created_at', -1]]
  Message.ensure_index [['recipient_id', 1], ['created_at', -1]]
  
  puts "Building indexes for Tag"
  drop_indexes_on(Tag)
  Tag.ensure_index [['name', 1], ['count', -1]]
  Tag.ensure_index [['count', -1]]
  
  puts "Building indexes for Tagging"
  drop_indexes_on(Tagging)
  Tagging.ensure_index [['name', 1], ['focus_id', 1], ['focus_type', 1], ['count', -1]]
  Tagging.ensure_index [['focus_id', 1], ['count', -1]]
  Tagging.ensure_index [['discussion_ids', 1], ['count', -1]]
  Tagging.ensure_index [['name', 1], ['comment_ids', 1]]
  
  puts "Building indexes for User"
  drop_indexes_on(User)
  User.ensure_index [['zooniverse_user_id', 1]], :unique => true
  User.ensure_index [['name', 1]]
  User.ensure_index [['moderator', 1]]
  User.ensure_index [['admin', 1]]
  User.ensure_index [['state', 1]]
end
