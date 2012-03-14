# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'neoscout/version'

Gem::Specification.new do |s|
  s.name        = 'neoscout'
  s.version     = NeoScout::VERSION
  s.summary     = 'Graph database schema extraction and validation tool'
  s.description = 'Tool for validating the schema of a free form graph databases and for reporting errors, including a REST access layer for runtime checking'
  s.author      = 'Stefan Plantikow'
  s.email       = 'stefanp@moviepilot.com'
  s.homepage    = 'http://moviepilot.github.com/neoscout'
  s.rubyforge_project = 'neoscout'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.bindir      = 'script'
  s.executables = `git ls-files -- script/*`.split("\n").map{ |f| File.basename(f) }
  s.default_executable = 'neoscout'
  s.executables = ['neoscout']
  s.licenses = ['PUBLIC DOMAIN WITHOUT ANY WARRANTY']
end
