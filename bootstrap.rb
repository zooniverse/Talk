#!/usr/bin/env ruby
require 'active_support/core_ext/string/inflections'

def input(prompt)
  print "#{ prompt }:  "
  gets.chomp
end

project, project_name, prefix = if ARGV.length == 3
  ARGV
elsif ARGV.length > 0
  puts 'Usage:'
  puts '                 project     project_name  project_prefix'
  puts "  ./bootstrap.rb planet_four 'Planet Four' PF"
  exit
else
  [
    input('Project (e.g. planet_four)'),
    input('Project name (e.g. Planet Four)'),
    input('Project prefix (e.g. PF)')
  ]
end

project_url = "http://www.#{ project.gsub('_', '') }.org"
url = "http://talk.#{ project.gsub('_', '') }.org"
cwd = Dir.pwd

Dir.mkdir "projects/#{ project }" unless Dir.exists? "projects/#{ project }"
Dir.chdir "projects/#{ project }"

File.open('config.coffee', 'w') do |out|
  out.puts <<-COFFEESCRIPT
socialDefaults =
  href: '#{ url }/'
  title: '#{ project_name }'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @#{ project }'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: '#{ project }'
    projectName: '#{ project_name }'
    prefix: '#{ prefix }'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: '#{ project }'
    projectName: '#{ project_name }'
    prefix: '#{ prefix }'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: '#{ project }'
    projectName: '#{ project_name }'
    prefix: '#{ prefix }'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/#{ project }/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: '#{ project }'
    projectName: '#{ project_name }'
    prefix: '#{ prefix }'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: '#{ project_url }/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: '#{ url }'
    app: app

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
COFFEESCRIPT
end

File.open('config.yml', 'w') do |out|
  out.puts <<-YAML
bucket: 'talk.#{ project.gsub('_', '') }.org'
external_scripts: []
external_styles: []
internal_scripts: []
internal_styles: []
YAML
end

File.open('project.styl', 'w'){ }

File.open('subject_viewer.coffee', 'w') do |out|
  out.puts <<-COFFEESCRIPT
DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class #{ project.classify }SubjectViewer extends DefaultSubjectViewer
  className: "#\{ DefaultSubjectViewer::className \} #{ project.dasherize }-subject-viewer"
  template: template

module.exports = #{ project.classify }SubjectViewer
COFFEESCRIPT
end

File.open('subject_viewer.eco', 'w'){ |out| out.puts "<img src=\"<%= @subject.location.standard %>\" class=\"main\" />" }

puts "created #{ project } at projects/#{ project }"
Dir.chdir cwd
puts `ruby ./configure.rb #{ project }`
