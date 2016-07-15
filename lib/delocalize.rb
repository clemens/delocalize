if defined?(Rails::Railtie)
  require 'delocalize/railtie'
elsif defined?(Rails::Initializer)
  raise "This version of delocalize is only compatible with Rails 3.0 or newer"
end

module Delocalize
  class ParserNotFound < ArgumentError; end

  autoload :Parsers,                 'delocalize/parsers'

  autoload :Parameters,              'delocalize/parameters'
  autoload :ParameterDelocalizing,   'delocalize/parameter_delocalizing'
  autoload :DelocalizableParameters, 'delocalize/delocalizable_parameters'

  autoload :NumberParser,            'delocalize/number_parser'
  autoload :DateTimeParser,          'delocalize/date_time_parser'
end
