# TODO:
#   * AM/PM calculation
#   * proper documentation (comments)
module Delocalize
  class LocalizedDateTimeParser
    class << self
      def parse(datetime, type)
        return unless datetime
        return datetime if datetime.respond_to?(:strftime) # already a Date/Time object -> no need to parse it

        input_formats(type).each do |original_format|
          format = apply_regex(original_format)

          if match = datetime.match(/^#{format}$/)
            return extract_object(type, match, calculate_order(original_format))
          end
        end
        default_parse(datetime, type)
      end

      private
      def default_parse(datetime, type)
        begin
          today = Date.current
          # parse set default year, month and day if not found
          parsed = Date._parse(datetime).reverse_merge(:year => today.year, :mon => today.mon, :mday => today.mday)

          if Date == type
            Date.civil(*parsed.values_at(:year, :mon, :mday).compact)
          elsif Time == type
            Time.local(*parsed.values_at(:year, :mon, :mday, :hour, :min, :sec).compact)
          # Rails doesn't really use DateTime ...
          # elsif DateTime == type
          #   DateTime.new(*parsed.values_at(:year, :mon, :mday, :hour, :min, :sec).compact)
          elsif ActiveSupport::TimeZone == type
            # might need to call in_time_zone here?
            Time.zone.local(*parsed.values_at(:year, :mon, :mday, :hour, :min, :sec).compact).in_time_zone
          end
        rescue
          datetime
        end
      end

      def input_formats(type)
        # Date uses date formats, all others use time formats
        type = type == Date ? :date : :time
        (@input_formats ||= {})[type] ||= I18n.t(:"#{type}.formats").slice(*I18n.t(:"#{type}.input.formats")).values
      end

      def month_names
        @month_names ||= I18n.t(:'date.month_names')
      end

      def abbr_month_names
        @abbr_month_names ||= I18n.t(:'date.abbr_month_names')
      end

      def day_names
        @day_names ||= I18n.t(:'date.day_names')
      end

      def abbr_day_names
        @abbr_day_names ||= I18n.t(:'date.abbr_day_names')
      end

      def apply_regex(format)
        format.gsub('%B', "(#{month_names.compact.join('|')})"). # long month name
          gsub('%b', "(#{abbr_month_names.compact.join('|')})"). # short month name
          gsub('%m', "(\\d{2})").                                # numeric month
          gsub('%A', "(#{day_names.compact.join('|')})").        # full day name
          gsub('%a', "(#{abbr_day_names.compact.join('|')})").   # short day name
          gsub('%Y', "(\\d{4})").                                # long year
          gsub('%y', "(\\d{2})").                                # short year
          gsub('%e', "(\\w?\\d{1,2})").                          # short day
          gsub('%d', "(\\d{2})").                                # full day
          gsub('%H', "(\\d{2})").                                # hour (24)
          gsub('%M', "(\\d{2})").                                # minute
          gsub('%S', "(\\d{2})")                                 # second
      end

      # TODO: maybe translate these to CLDR strings?
      # see http://www.unicode.org/reports/tr35/tr35-11.html#Date_Format_Patterns
      def calculate_order(format)
        format.gsub(/[^%BbmAaYyedHMS]/, '').split('%').reject(&:blank?)
      end

      def extract_object(type, match, order)
        if Date == type
          Date.civil(*extract_date_values(match, order))
        elsif Time == type
          Time.local(*extract_time_values(match, order))
        # Rails doesn't really use DateTime ...
        # elsif DateTime == type
        #   DateTime.new(*extract_time_values(match, order))
        elsif ActiveSupport::TimeZone == type
          # might need to call in_time_zone here?
          Time.local(*extract_time_values(match, order))
        end
      end

      def extract_date_values(match, order)
        y = if order.include?('Y')
          match[order.index('Y')+1].to_i
        elsif order.include?('y')
          # TODO: re-think if this is good behavior
          # we always assume that we're moving in the 21st century
          2000 + match[order.index('y')+1].to_i
        else
          Time.current.year
        end

        m = if order.include?('B')
          month_names.index(match[order.index('B')+1])
        elsif order.include?('b')
          abbr_month_names.index(match[order.index('b')+1])
        elsif order.include?('m')
          match[order.index('m')+1].to_i
        else
          Time.current.month
        end

        d = if order.include?('e')
          match[order.index('e')+1].to_i
        elsif order.include?('d')
          match[order.index('d')+1].to_i
        else
          Time.current.day
        end

        return [y, m, d]
      end

      def extract_time_values(match, order)
        # default everything to 0 just like Time.local would
        h = order.include?('H') ? match[order.index('H')+1].to_i : 0
        m = order.include?('M') ? match[order.index('M')+1].to_i : 0
        s = order.include?('S') ? match[order.index('S')+1].to_i : 0

        [extract_date_values(match, order), h, m, s].flatten
      end
    end
  end
end