# TODO Rethink: Shouldn't this return numbers instead of reformatted strings?
module Delocalize
  module Parsers
    class Number
      # Parse numbers removing unneeded characters and replacing decimal separator
      # through I18n. This will return a valid Ruby Numeric value (as String).
      def parse(value)
        return value unless value.is_a?(String)

        separator, delimiter = I18n.t([:separator, :delimiter], :scope => :'number.format')
        if value.index(separator).present? || (delimiter != '.' || (value.count('.') > 1))
          value.gsub(delimiter, '').gsub(separator, '.')
        else
          value
        end
      end
    end
  end
end
