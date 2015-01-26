# -*- encoding: utf-8 -*-
# stub: aibot 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = 'aibot'
  s.version = '0.1.0'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.require_paths = ['lib']
  s.authors = ['']
  s.date = '2014-10-30'
  s.email = 'youremail@example.com'
  s.executables = ['aibot']
  s.files = ['bin/aibot', 'lib/aibot.rb']
  s.homepage = 'http://yoursite.example.com'
  s.rubygems_version = '2.2.2'
  s.summary = 'What this thing does'

  if s.respond_to? :specification_version
    s.specification_version = 4

    s.add_dependency(%q<ffi-ncurses>, ['>= 0.0.0', '~> 0.0'])
    s.add_dependency(%q<btce>, ['>= 0.0.0', '~> 0.0'])
  else
    s.add_dependency(%q<ffi-ncurses>, ['>= 0.0.0', '~> 0.0'])
    s.add_dependency(%q<btce>, ['>= 0.0.0', '~> 0.0'])
  end
end
