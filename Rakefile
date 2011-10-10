require 'bundler/gem_tasks'
require 'rake'

### Tests ###

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << %w{ lib test }
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

### Documentation ### 

require 'yard'
require 'yard/rake/yardoc_task'

desc "Generate documentation"
task :doc => 'doc:generate'

namespace :doc do
  GEM_ROOT = File.dirname(__FILE__)
  RDOC_ROOT = File.join(GEM_ROOT, 'doc')

  YARD::Rake::YardocTask.new(:generate) do |rdoc|
    rdoc.files = Dir.glob(File.join(GEM_ROOT, 'lib', '**', '*.rb')) +
      [ File.join(GEM_ROOT, 'README.md') ]
    rdoc.options = ['--output-dir', RDOC_ROOT, '--readme', 'README.md']
  end

  desc "Remove generated documentation"
  task :clobber do
    FileUtils.rm_rf(RDOC_ROOT) if File.exists?(RDOC_ROOT)
  end
end
