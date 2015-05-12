# coding: utf-8

Gem::Specification.new do |spec|
  spec.name        = 'aibot'
  spec.version     = 0.1
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Steve Soltys']
  spec.email       = ['steve.soltys@rutgers.edu']
  spec.homepage    = 'http://github.com/stevesoltys/aibot'
  spec.summary     = 'A modular chatbot.'
  spec.description = 'A modular chatbot.'

  # TODO: Runtime dependencies.

  spec.files        = Dir.glob("{bin,test,lib}/**/*") + %w(LICENSE README.md)
  spec.executables  = 'aibot'
  spec.require_path = 'lib'
end