require 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'neoscout'
  s.version     = NeoScout::VERSION
  s.summary     = 'Graph database schema extraction and validation tool'
  s.author      = 'stefanp@moviepilot.com'
  s.files       = 'lib/**/*'
  s.executables = `git ls-files -- lib/neoscout/bin/*`.split("\n").map{|f| File.basename(f)}
  # s.rubyforge_project = 'neoscout'
end
