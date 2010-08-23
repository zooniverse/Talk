desc "Rebuild Xapian indexes"
task :rebuild_indexes => :environment do
  `rm -rf index/*`
  Comment.all.each do |comment|
    comment.save
  end
end