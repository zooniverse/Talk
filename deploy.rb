#!/usr/bin/env ruby

require 'pathname'
projects = Dir['projects/*'].collect{ |path| Pathname.new(path).basename.to_s }.sort
names = ARGV[0] == 'all' ? projects : [ARGV[0]]

puts "Deploy to #{ names.join(' and ') }? (y/n)"
unless ::STDIN.gets.chomp =~ /^y/i
  puts 'Aborting'
  exit
end

names.each do |name|
  ARGV[0] = name
  load 'configure.rb'
  load 'build.rb'
end
