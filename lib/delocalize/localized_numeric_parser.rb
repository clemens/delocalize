# TODO:
#   * proper documentation (comments)
module Delocalize
  class LocalizedNumericParser
    class << self
      # Parse numbers removing unneeded characters and replacing decimal separator
      # through I18n. This will return a valid Ruby Numeric value (as String).
      def parse(value)
        if value.is_a?(String)
          separator = I18n.t(:'number.format.separator')
          delimiter = I18n.t(:'number.format.delimiter')
          value = value.gsub(delimiter, '').gsub(separator, '.')
        end
        value
      end
    end
  end
end
