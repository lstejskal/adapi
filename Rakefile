require 'bundler/gem_tasks'
require 'rake'

task :default do
  # run examples using current gem environment
  # example: rake example=find_campaigns
  #
  if ENV.keys.include?("example")
    ENV["example"] += ".rb" unless ENV["example"] =~ /\.rb$/
    exec "ruby -Ilib examples/%s" % ENV["example"]

  # load example into irb using current gem environment
  # example: rake irb=find_campaigns
  #
  elsif ENV.keys.include?("irb")
    exec "irb -Ilib -Iexamples -r%s" % ENV["irb"].gsub(/\.rb$/, '')

  # run default task: test
  #
  else
    Rake::Task['test'].invoke
  end
end

### Tests ###

# run all tests except integrations tests
#
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << %w{ lib test }
  test.pattern = 'test/unit/*_test.rb'
  test.verbose = true
end

require 'rake/testtask'
Rake::TestTask.new(:"test:integration") do |test|
  test.libs << %w{ lib test }
  test.pattern = 'test/integration/*_test.rb'
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
