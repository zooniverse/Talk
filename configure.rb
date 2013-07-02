#!/usr/bin/env ruby

require 'pathname'
require 'yaml'

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
group_viewer = Pathname.new File.absolute_path "projects/#{ PROJECT }/group_viewer.coffee"
group_view = Pathname.new File.absolute_path "projects/#{ PROJECT }/group_viewer.eco"
style = Pathname.new File.absolute_path "projects/#{ PROJECT }/project.styl"

paths = {
  config => Pathname.new('app/lib/config.coffee'),
  subject_viewer => Pathname.new('app/controllers/subject_viewer.coffee'),
  subject_view => Pathname.new('app/views/subjects/viewer.eco'),
  group_viewer => Pathname.new('app/controllers/group_viewer.coffee'),
  group_view => Pathname.new('app/views/groups/viewer.eco'),
  style => Pathname.new('css/project.styl')
}

paths.each_pair do |path, link_path|
  default_path = Pathname.new File.absolute_path "project_defaults/#{ link_path.basename }"
  
  if path.exist?
    File.unlink link_path if link_path.symlink?
    File.symlink path, link_path
  elsif default_path.exist?
    File.unlink link_path if link_path.symlink?
    File.symlink default_path, link_path
  else
    File.unlink link_path if link_path.symlink?
  end
end

CONFIG = YAML.load File.read "projects/#{ PROJECT }/config.yml"

puts "Configured for #{ PROJECT }"
