Gem::Specification.new do |s|
  s.name = 'delocalize'
  s.version = '1.0.0.beta1'

  s.authors = ['Clemens Kofler']
  s.summary = %q{Localized date/time and number parsing}
  s.description = %q{Delocalize is a tool for parsing localized dates/times and numbers.}
  s.email = %q{clemens@railway.at}
  s.extra_rdoc_files = ['README.markdown']
  s.files = Dir['{bin,lib}/**/*', 'README*', '*LICENSE*']
  s.homepage = %q{http://github.com/clemens/delocalize}
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 3.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'timecop'
end
