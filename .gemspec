Gem::Specification.new do |s|
  s.name            = 'foraneus'
  s.version         = '0.0.1'
  s.platform        = Gem::Platform::RUBY
  s.authors         = ['Gianfranco Zas']
  s.email           = 'snmgian@gmail.com'
  s.homepage        = 'http://rubygems.org/gems/rake'
  s.summary         = 'Validates and transform external data.'
  s.description     = 'Provides validation and transformation mechanisms to external data.'

  s.files           = Dir.glob("{lib}/**/*") + %w(COPYING COPYING.LESSER README.md)

  s.add_development_dependency('rspec')
end
