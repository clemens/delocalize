require 'delocalize/i18n_ext'

if defined?(Rails::Railtie)
  require 'delocalize/railtie'
elsif defined?(Rails::Initializer)
  raise "This version of delocalize is only compatible with Rails 3.0 or newer"
end

module Delocalize
  autoload :Delocalizable,           'delocalize/delocalizable'
  autoload :LocalizedDateTimeParser, 'delocalize/localized_date_time_parser'
  autoload :LocalizedNumericParser,  'delocalize/localized_numeric_parser'
end
