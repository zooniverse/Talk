#!/usr/bin/env ruby

unless defined?(CONFIG)
  puts "Do not run this script directly"
  puts "Instead use configure.rb or deploy.rb"
  exit
end

system('node version.js') or exit(1)

require 'aws-sdk'
AWS.config access_key_id: ENV['S3_ACCESS_ID'], secret_access_key: ENV['S3_SECRET_KEY']
s3 = AWS::S3.new
bucket = s3.buckets[CONFIG['bucket']]
bucket_path = CONFIG['bucket_path']
bucket_path.sub(/^\//, '') if bucket_path

build = <<-BASH
rm -rf build
cp -R public pre_build_public
cp -RL public build_public
rm -rf public
mv build_public public
echo 'Building application...'
haw build
mv public build
mv pre_build_public public
BASH

timestamp = `date -u +%Y-%m-%d_%H-%M-%S`.chomp

compress = <<-BASH
echo 'Compressing...'

timestamp=#{ timestamp }

./node_modules/clean-css/bin/cleancss build/application.css -o "build/application.css"
gzip -9 -c "build/application.js" > "build/application-$timestamp.js"
gzip -9 -c "build/application.css" > "build/application-$timestamp.css"
rm build/application.js
rm build/application.css
BASH

system build
system compress

index = File.read 'build/index.html'
index.gsub! 'application.js', "application-#{ timestamp }.js"
index.gsub! 'application.css', "application-#{ timestamp }.css"
File.open('build/index.html', 'w'){ |f| f.puts index }

error = File.read 'build/error.html'
error.gsub! 'application.js', "application-#{ timestamp }.js"
error.gsub! 'application.css', "application-#{ timestamp }.css"
File.open('build/error.html', 'w'){ |f| f.puts error }

working_directory = File.expand_path Dir.pwd
Dir.chdir 'build'

to_upload = []

if ARGV[1] == 'quick'
  %w(js css html).each{ |ext| to_upload << Dir["**/*.#{ ext }*"] }
  to_upload.flatten!
else
  to_upload = Dir['**/*'].reject{ |path| File.directory? path }
end

to_upload.delete 'index.html'
total = to_upload.length

to_upload.each.with_index do |file, index|
  content_type = case File.extname(file)
  when '.html'
    'text/html'
  when '.js'
    'application/javascript'
  when '.css'
    'text/css'
  when '.gz'
    'application/x-gzip'
  when '.ico'
    'image/x-ico'
  else
    `file --mime-type -b #{ file }`.chomp
  end
  
  puts "#{ '%2d' % (index + 1) } / #{ '%2d' % (total + 1) }: Uploading #{ file } as #{ content_type } to #{ bucket_path || '/' }"
  options = { file: file, acl: :public_read, content_type: content_type }
  
  if content_type == 'application/javascript' || content_type == 'text/css'
    options[:content_encoding] = 'gzip'
  end
  
  file_path = [bucket_path, file].compact.join '/'
  bucket.objects[file_path].write options
end

puts "#{ '%2d' % (total + 1) } / #{ '%2d' % (total + 1) }: Uploading index.html as text/html to #{ bucket_path || '/' }"
bucket.objects[[bucket_path, 'index.html'].compact.join('/')].write file: 'index.html', acl: :public_read, content_type: 'text/html', cache_control: 'no-cache, must-revalidate'

Dir.chdir working_directory
`rm -rf build`
puts 'Done!'
