#!/usr/bin/env ruby

require 'pathname'
projects = Dir['projects/*'].collect{ |path| Pathname.new(path).basename.to_s }.sort
names = ARGV[0] == 'all' ? projects : [ARGV[0]]

names.each do |name|
  ARGV[0] = name
  require_relative 'configure'
  require_relative 'build'
end
