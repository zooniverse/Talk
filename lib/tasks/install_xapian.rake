# Remove xapian gem dependencies before installing

desc "Installs xapian"
task :install_xapian => :environment do
  `curl -O http://oligarchy.co.uk/xapian/1.2.2/xapian-core-1.2.2.tar.gz`
  `curl -O http://oligarchy.co.uk/xapian/1.2.2/xapian-bindings-1.2.2.tar.gz`
  `tar -xzf xapian-core-1.2.2.tar.gz`
  `tar -xzf xapian-bindings-1.2.2.tar.gz`
  Dir.chdir('xapian-core-1.2.2')
  puts "Installing xapian-core"
  `./configure && make && sudo make install`
  Dir.chdir('../xapian-bindings-1.2.2')
  puts "Installing xapian-bindings"
  `./configure --with-ruby && make && sudo make install`
  Dir.chdir('../')
  `rm -rf xapian*`
end