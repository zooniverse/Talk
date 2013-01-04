#!/usr/bin/env ruby

require 'pathname'
require 'yaml'

def ensure_file_at(path)
   return if path.exist?
   puts "#{ path } doesn't exist"
   exit
end

projects = Dir['projects/*'].collect{ |path| Pathname.new(path).basename.to_s }.sort

unless PROJECT = ARGV[0]
  puts "No project selected\nAvailable: #{ projects.join(', ') }"
  exit
end

unless projects.include?(PROJECT)
  puts "Project not available\nAvailable: #{ projects.join(', ') }"
  exit
end

config = Pathname.new File.absolute_path "projects/#{ PROJECT }/config.coffee"
subject_viewer = Pathname.new File.absolute_path "projects/#{ PROJECT }/subject_viewer.coffee"
subject_view = Pathname.new File.absolute_path "projects/#{ PROJECT }/subject_viewer.eco"
style = Pathname.new File.absolute_path "projects/#{ PROJECT }/project.styl"

paths = {
  config => Pathname.new('app/lib/config.coffee'),
  subject_viewer => Pathname.new('app/controllers/subject_viewer.coffee'),
  subject_view => Pathname.new('app/views/subjects/viewer.eco'),
  style => Pathname.new('css/project.styl')
}

paths.each_pair do |path, link_path|
  ensure_file_at path
  File.unlink link_path if link_path.symlink?
  File.symlink path, link_path
end

CONFIG = YAML.load File.read "projects/#{ PROJECT }/config.yml"

puts "Configured for #{ PROJECT }"
