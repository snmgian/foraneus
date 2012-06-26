Gem::Specification.new do |s|
  s.name            = 'foraneus'
  s.version         = '0.0.1'
  s.platform        = Gem::Platform::RUBY
  s.authors         = ['Gianfranco Zas']
  s.summary         = 'TODO PLEASE'
  s.description     = 'TODO PLEASE'

  s.files           = Dir.glob("{lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)

  s.add_development_dependency('rspec', '2.10.0')
  s.add_development_dependency('simplecov', '0.6.4')
end
