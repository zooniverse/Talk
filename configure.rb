#!/usr/bin/env ruby

require 'active_support/core_ext/hash'
require 'pathname'
require 'yaml'
require 'erb'

class Dependencies
  attr_accessor :config
  
  def initialize
    find_config
  end
  
  def render_index
    File.open('public/index.html', 'w'){ |out| out.puts index_html }
  end
  
  def external_styles
    @config['external_styles'].collect do |href|
      "<link rel=\"stylesheet\" href=\"#{ href }\" />"
    end.join("\n    ")
  end
  
  def external_scripts
    @config['external_scripts'].collect do |href|
      "<script src=\"#{ href }\" type=\"text/javascript\" charset=\"utf-8\"></script>"
    end.join("\n    ")
  end
  
  protected
  
  def find_config
    @config = YAML.load config_file.read
    @config.reverse_merge!({
      'external_scripts' => [],
      'external_styles' => [],
      'internal_scripts' => [],
      'internal_styles' => []
    })
  end
  
  def config_file
    Pathname.new "projects/#{ PROJECT }/config.yml"
  end
  
  def index_html
    ERB.new(file_with_default('index.html')).result binding
  end
  
  def file_with_default(name)
    project_file = "projects/#{ PROJECT }/#{ name }"
    default_file = "project_defaults/#{ name }"
    File.read File.exists?(project_file) ? project_file : default_file
  end
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
subject_preview = Pathname.new File.absolute_path "projects/#{ PROJECT }/subject_preview.eco"
group_viewer = Pathname.new File.absolute_path "projects/#{ PROJECT }/group_viewer.coffee"
group_view = Pathname.new File.absolute_path "projects/#{ PROJECT }/group_viewer.eco"
style = Pathname.new File.absolute_path "projects/#{ PROJECT }/project.styl"

paths = {
  config => Pathname.new('app/lib/config.coffee'),
  subject_viewer => Pathname.new('app/controllers/subject_viewer.coffee'),
  subject_view => Pathname.new('app/views/subjects/viewer.eco'),
  subject_preview => Pathname.new('app/views/subjects/preview.eco'),
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

dependencies = Dependencies.new
dependencies.render_index
CONFIG = dependencies.config

puts "Configured for #{ PROJECT }"
