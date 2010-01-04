require 'delocalize/localized_numeric_parser'

Numeric.class_eval do
  class << self
    def parse_localized(value)
      Delocalize::LocalizedNumericParser.parse(value)
    end
  end
end
