require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rspec'
require 'lib/version'

desc 'Run all rspecs'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.fail_on_error = true
  spec.verbose       = false
  spec.rspec_opts    = ['--backtrace']
end

RDoc::Task.new(:rdoc) do |rdoc|
  # rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("lib/**/*.rb")
end

task :default  => :spec
