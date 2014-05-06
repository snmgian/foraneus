Gem::Specification.new do |s|
  s.name            = 'foraneus'
  s.version         = '0.0.3'
  s.platform        = Gem::Platform::RUBY
  s.authors         = ['Gianfranco Zas']
  s.email           = 'snmgian@gmail.com'
  s.homepage        = 'https://github.com/snmgian/foraneus'
  s.summary         = 'Validates and transform external data.'
  s.description     = 'Provides validation and transformation mechanisms to external data.'
  s.licenses        = ['LGPL']

  s.files           = Dir.glob("{lib}/**/*") + %w(COPYING COPYING.LESSER README.md)
  s.test_files      = Dir.glob("{spec}/**/*")

  s.add_development_dependency('rspec')
end
