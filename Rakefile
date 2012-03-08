require 'bundler'
Bundler.require

require 'rake'
require 'rdoc/task'
require 'rspec'
require 'rspec/core/rake_task'
require 'lib/version'

desc 'Run all rspecs'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.fail_on_error = true
  spec.verbose       = false
#  spec.rspec_opts    = ['--backtrace']
end

desc 'Run rdoc over project sources'
RDoc::Task.new(:rdoc) do |rdoc|
  # rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("lib/**/*.rb")
end

desc 'Run irb in project environment'
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end

task :irb => :console
task :default  => :spec
