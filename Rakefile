require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Test the delocalize gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/delocalize_test.rb'
  t.verbose = true
end

desc 'Default: run unit tests.'
task :default => :test
