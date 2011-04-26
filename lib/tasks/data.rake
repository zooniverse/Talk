# Load the development database from the development dump:  rake load_data[development]
# Load the production database from the development dump:   rake load_data[development,production]
desc "Loads a database"
task :load_data, :load_from, :restore_to, :needs => :environment do |t, args|
  args.with_defaults(:load_from => Rails.env, :restore_to => Rails.env)
  `mongorestore --drop --objcheck dump/talk-#{ args[:load_from] } #{ connection_for(args[:restore_to]) }`
end

# Dump the development database to the development directory:   rake dump_data[development]
# Dump the production database to the development directory:    rake dump_data[production, development]
desc "Dumps a database"
task :dump_data, :load_from, :dump_to, :needs => :environment do |t, args|
  args.with_defaults(:load_from => Rails.env, :dump_to => Rails.env)
  load_dir = "talk-beta-#{ args[:load_from] }"
  dump_dir = "talk-beta-#{ args[:dump_to] }"
  options = connection_for args[:load_from]
  options.delete '--db'
  
  commands = ["mongodump --db #{ load_dir } --out dump/tmp/ #{ options }"]
  commands << "mv dump/tmp/#{ load_dir } dump/tmp/#{ dump_dir }" unless load_dir == dump_dir
  commands << "rm -rf dump/#{ dump_dir }" if Dir.exists?("dump/#{ dump_dir }")
  commands << "mv dump/tmp/#{ dump_dir } dump/"
  commands << "rm -r dump/tmp"
  
  `#{ commands.join(" && ") }`
end

def connection_for(environment)
  config = YAML.load_file(Rails.root + 'config' + 'mongodb.yml')[environment]
  options = { "--host" => "#{ config['host'] }", "--db" => "#{ config['database'] }", "--port" =>  "#{ config['port'] }" }
  options["--username]"] = "#{ config['username'] }" if config.has_key?('username')
  options["--password"] = "\"#{ config['password'] }\"" if config.has_key?('password')
  
  def options.to_s
    collect{ |k, v| " #{k} #{v}" }.join
  end
  
  options
end
