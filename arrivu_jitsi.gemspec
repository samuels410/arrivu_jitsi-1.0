# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arrivu_jitsi/version'

Gem::Specification.new do |gem|
  gem.name          = 'arrivu_jitsi'
  gem.version       = ArrivuJitsi::VERSION
  gem.authors       = ['samuel santhosh']
  gem.email         = ['samuel@arrivusystems.com']
  gem.description   = %q{Arrivu Jitsi Meet plugin for the Arrivu LMS. It allows teachers and administrators to create and launch WEbEx conferences directly from their courses.}
  gem.summary       = %q{Jitsi Meet integration for Arrivu Info Tech Private Limited. (http://arrivuapps.com).}
  gem.homepage      = 'http://arrivuapps.com'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w{app lib}

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'pry'
end

