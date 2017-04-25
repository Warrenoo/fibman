# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fib/version'

Gem::Specification.new do |spec|
  spec.name          = 'fib'
  spec.version       = Fib::VERSION
  spec.authors       = ['Warrenoo']
  spec.email         = ['541991a@gmail.com']
  spec.summary       = '权限管理'
  spec.description   = '多模块持久化权限管理系统'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activesupport', '~> 0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0'

  spec.add_development_dependency 'rspec', '~> 0'
  spec.add_development_dependency 'rubocop-rspec', '~> 0'
  spec.add_development_dependency 'simplecov', '~> 0'
end
