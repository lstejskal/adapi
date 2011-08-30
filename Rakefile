require 'bundler/gem_tasks'
require 'rake'

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << %w{ lib test }
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

