# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ideeli-statsd/version"

Gem::Specification.new do |s|
  s.name        = "ideeli-statsd"
  s.version     = Ideeli::Statsd::VERSION
  s.authors     = ["patrick brisbin"]
  s.email       = ["pbrisbin@ideeli.com"]
  s.homepage    = "http://github.com/ideeli/ideeli-statsd"
  s.summary     = %q{A wrapper gem for the statsd-ruby gem with auto-namespacing}
  s.description = %q{Namespacing specific to ideeli's needs is added before calling out to statsd}

  s.rubyforge_project = "ideeli-statsd"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
