desc "Rebuild Xapian indexes"
task :rebuild_indexes, :environment => do
  Comment.all.each{ |comment| comment.save }
end