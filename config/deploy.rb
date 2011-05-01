set :application, "set your application name here"
set :repository,  "set your repository location here"

set :scm, :git

role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
role :db,  "your slave db-server here"

set :deploy_to, "your directory here"
set :scm, :git
set :repository, "your repository here"
set :deploy_via, :remote_cache
default_run_options[:pty] = true

before "deploy:restart", :deploy_rotate

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

task :disable_web, :roles => :app do
  on_rollback { delete "#{current_path}/public/index.html" }
  maintenance = File.read("app/views/layouts/maintenance.html")
  put maintenance, "#{current_path}/public/index.html", :mode => 0644
end

task :enable_web, :roles => :app do
  run "rm #{current_path}/public/index.html"
end

desc "Run all tasks that need to be run before application restart"
task :deploy_rotate do
  # symlinks
  # permissions_check
  # god_rotate
  # memcache_rotate
end

# Create required symlinks
desc "Configure local database for Rails application"
task :symlinks do
  database
  settings
  memcache_link
end

desc "Database config"
task :database do
  run "ln -s #{shared_path}/database.yml #{current_path}/config/database.yml"
end

desc "Site settings"
task :settings do
  run "ln -s #{shared_path}/site_settings.yml #{current_path}/config/site_settings.yml"
end

desc "Memcache config"
task :memcache_link do
  run "ln -s #{shared_path}/memcache.yml #{current_path}/config/memcache.yml"
end

# Tasks to set correct permissions on files
desc "Copy production config files into proper locations"
task :permissions_check do 
  shared
  current
  logs
end

desc "Shared path permissions"
task :shared do 
  run "chown -R www-data:www-data #{shared_path}"
end

desc "Shared path permissions"
task :current do 
  run "cd #{current_path} && chown -R www-data:www-data *"
end

desc "Log file permissons"
task :logs do
  run "touch /mnt/log/production.log"
  run "chown -R www-data:www-data /mnt/log"
end

desc "Stop and start god"
task :god_rotate do
  # run "killall god"
  run "/usr/bin/ruby1.8 /usr/bin/god -c god/god.config -l god/god.log"
end

desc "Stop and start memcached"
task :memcache_rotate do
  run "killall memcached"
  run "memcached -u root -d -m 256 -p 11211"
end
