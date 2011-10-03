Gem::Specification.new do |s|
  s.name = %q{delocalize}
  s.version = "0.2.3"

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
     "init.rb",
     "lib/delocalize.rb",
     "lib/delocalize/i18n_ext.rb",
     "lib/delocalize/localized_date_time_parser.rb",
     "lib/delocalize/localized_numeric_parser.rb",
     "lib/delocalize/rails_ext.rb",
     "lib/delocalize/rails_ext/action_view.rb",
     "lib/delocalize/rails_ext/active_record.rb",
     "lib/delocalize/rails_ext/time_zone.rb",
     "lib/delocalize/ruby_ext.rb",
     "lib/delocalize/ruby_ext/date.rb",
     "lib/delocalize/ruby_ext/datetime.rb",
     "lib/delocalize/ruby_ext/numeric.rb",
     "lib/delocalize/ruby_ext/time.rb",
     "tasks/documentation.rb",
     "tasks/testing.rb"
  ]
  s.homepage = %q{http://github.com/clemens/delocalize}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.test_files = [
    "test/delocalize_test.rb",
     "test/test_helper.rb",
     "test/rails2_app/config/environments/test.rb",
     "test/rails2_app/config/environment.rb",
     "test/rails2_app/config/initializers/new_rails_defaults.rb",
     "test/rails2_app/config/initializers/session_store.rb",
     "test/rails2_app/config/routes.rb",
     "test/rails2_app/config/boot.rb",
     "test/rails2_app/app/controllers/application_controller.rb",
     "test/rails3_app/config/environments/test.rb",
     "test/rails3_app/config/environment.rb",
     "test/rails3_app/config/initializers/new_rails_defaults.rb",
     "test/rails3_app/config/initializers/session_store.rb",
     "test/rails3_app/config/routes.rb",
     "test/rails3_app/config/boot.rb",
     "test/rails3_app/app/controllers/application_controller.rb",
     "test/rails3.1_app/config/environments/test.rb",
     "test/rails3.1_app/config/environment.rb",
     "test/rails3.1_app/config/initializers/new_rails_defaults.rb",
     "test/rails3.1_app/config/initializers/session_store.rb",
     "test/rails3.1_app/config/routes.rb",
     "test/rails3.1_app/config/boot.rb",
     "test/rails3.1_app/app/controllers/application_controller.rb"
  ]

  s.add_dependency 'rails', '>= 3.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.4'
  s.add_development_dependency 'timecop', '~> 0.3.5'
end
