Gem::Specification.new do |s|
  s.name = %q{delocalize}
  s.version = "1.0.0.beta1"

  s.authors = ["Clemens Kofler"]
  s.summary = %q{Localized date/time and number parsing}
  s.description = %q{Delocalize is a tool for parsing localized dates/times and numbers.}
  s.email = %q{clemens@railway.at}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "MIT-LICENSE",
    "Rakefile",
    "VERSION",
    "lib/delocalize.rb",
    "lib/delocalize/action_view.rb",
    "lib/delocalize/delocalizable.rb",
    "lib/delocalize/localized_date_time_parser.rb",
    "lib/delocalize/localized_numeric_parser.rb",
    "lib/delocalize/railtie.rb",
  ]
  s.homepage = %q{http://github.com/clemens/delocalize}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.test_files = [
    "test/database.yml",
    "test/delocalizable_test.rb",
    "test/delocalize_test.rb",
    "test/isolated_test_helper.rb",
    "test/localized_date_time_parser_test.rb",
    "test/localized_numeric_parser_test.rb",
    "test/test_helper.rb",
  ]

  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'i18n'
  s.add_development_dependency 'rails', '>= 3.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.4'
  s.add_development_dependency 'timecop', '~> 0.3.5'
  s.add_development_dependency 'mocha', '~> 0.10.2'
end
