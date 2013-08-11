require 'delocalize/i18n_ext'
require 'delocalize/localized_date_time_parser'

if defined?(Rails::Railtie)
  require 'delocalize/railtie'
elsif defined?(Rails::Initializer)
  raise "This version of delocalize is only compatible with Rails 3.0 or newer"
end

module Delocalize
  autoload :Delocalizing, 'delocalize/delocalizing'

  autoload :LocalizedNumericParser,  'delocalize/localized_numeric_parser'
  autoload :LocalizedDateTimeParser, 'delocalize/localized_date_time_parser'
end
