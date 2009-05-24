# TODO:
#   * AM/PM calculation
#   * proper documentation (comments)
module Delocalize
  class LocalizedDateTimeParser
    class << self
      def parse(datetime, type)
        return unless datetime
        return datetime if datetime.respond_to?(:strftime) # already a Date/Time object -> no need to parse it

        translate_month_and_day_names(datetime)
        input_formats(type).each do |original_format|
          format = apply_regex(original_format)

          if match = datetime.match(/^#{format}$/)
            datetime = DateTime.strptime(datetime, original_format)

            return(if Date == type
              datetime.to_date
            elsif Time == type
              Time.local(datetime.year, datetime.mon, datetime.mday, datetime.hour, datetime.min, datetime.sec)
            elsif ActiveSupport::TimeZone == type
              Time.zone.local(datetime.year, datetime.mon, datetime.mday, datetime.hour, datetime.min, datetime.sec).in_time_zone
            # Rails doesn't really use DateTime ...
            # else
            #   datetime
            end)
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

      def translate_month_and_day_names(datetime)
        translated = (month_names + abbr_month_names + day_names + abbr_day_names).compact
        original = (Date::MONTHNAMES + Date::ABBR_MONTHNAMES + Date::DAYNAMES + Date::ABBR_DAYNAMES).compact

        translated.each_with_index { |name, i| datetime.gsub!(name, original[i]) }
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
        format.gsub('%B', "(#{Date::MONTHNAMES.compact.join('|')})"). # long month name
          gsub('%b', "(#{Date::ABBR_MONTHNAMES.compact.join('|')})"). # short month name
          gsub('%m', "(\\d{2})").                                     # numeric month
          gsub('%A', "(#{Date::DAYNAMES.join('|')})").                # full day name
          gsub('%a', "(#{Date::ABBR_DAYNAMES.join('|')})").           # short day name
          gsub('%Y', "(\\d{4})").                                     # long year
          gsub('%y', "(\\d{2})").                                     # short year
          gsub('%e', "(\\w?\\d{1,2})").                               # short day
          gsub('%d', "(\\d{2})").                                     # full day
          gsub('%H', "(\\d{2})").                                     # hour (24)
          gsub('%M', "(\\d{2})").                                     # minute
          gsub('%S', "(\\d{2})")                                      # second
      end
    end
  end
end