desc "Rebuild Xapian indexes"
task :rebuild_indexes => :environment do
  `rm -rf index/*`
  [Asset, Discussion, Comment].each do |model|
    puts "Rebuilding #{model.name}"
    model.all.each do |document|
      document.save
    end
  end
end