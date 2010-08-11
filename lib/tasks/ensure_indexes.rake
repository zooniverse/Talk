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
  
  puts "Building indexes for Comment"
  # drop_indexes_on(Comment)
  Comment.ensure_index [['discussion_id', 1], ['created_at', -1]]
  Comment.ensure_index [['tags', 1]]
  Comment.ensure_index [['assets', 1]]
  
  puts "Building indexes for Discussion"
  drop_indexes_on(Discussion)
  Discussion.ensure_index [['focus_id', 1], ['created_at', -1]]
  Discussion.ensure_index [['tags', 1]]
  Discussion.ensure_index [['assets', 1]]
  
  puts "Building indexes for Tag"
  drop_indexes_on(Tag)
  Tag.ensure_index [['tags', 1]]
  
  puts "Building indexes for User"
  drop_indexes_on(User)
  User.ensure_index [['zooniverse_user_id', 1]], :unique => true
  User.ensure_index [['collections.tags', 1]]
  User.ensure_index [['collections.asset_ids', 1]]
end
