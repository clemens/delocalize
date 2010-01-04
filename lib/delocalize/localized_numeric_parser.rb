# TODO:
#   * proper documentation (comments)
module Delocalize
  class LocalizedNumericParser
    class << self
      # Parse numbers removing unneeded characters and replacing separator
      # through I18n. The return will be a valid ruby Numeric value (as string).
      def parse(value)
        if value.is_a?(String)
          value     = value.dup
          separator = I18n.t(:'number.format.separator')
          value.gsub!(/[^0-9\-#{separator}]/, '')
          value.gsub!(separator, '.')
        end
        value
      end
    end
  end
end
