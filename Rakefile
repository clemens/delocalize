require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require File.expand_path(File.join(File.dirname(__FILE__), 'tasks/distribution'))
require File.expand_path(File.join(File.dirname(__FILE__), 'tasks/documentation'))
require File.expand_path(File.join(File.dirname(__FILE__), 'tasks/testing'))

desc 'Default: run unit tests.'
task :default => :test

desc 'Run unit tests against Rails 2 and 3.'
task :test_all do
  puts "\n * Running tests against Rails 2...\n\n"
  sh "rake test"
  puts "\n * Running tests against Rails 3...\n\n"
  sh "rake test RAILS_VERSION=3"
end
