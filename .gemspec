Gem::Specification.new do |s|
  s.name            = 'foraneus'
  s.version         = '0.0.1'
  s.platform        = Gem::Platform::RUBY
  s.authors         = ['Gianfranco Zas']
  s.summary         = 'TODO PLEASE'
  s.description     = 'TODO PLEASE'

  s.files           = Dir.glob("{lib}/**/*") + %w(COPYING COPYING.LESSER README.md)

  s.add_development_dependency('redcarpet', '2.1.1')
  s.add_development_dependency('rspec', '2.10.0')
  s.add_development_dependency('simplecov', '0.6.4')
  s.add_development_dependency('yard', '0.8.2.1')
end
