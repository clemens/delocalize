# TODO:
#   * proper documentation (comments)
module Delocalize
  class LocalizedNumericParser
    class << self
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
