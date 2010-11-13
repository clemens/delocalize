# TODO:
#   * AM/PM calculation
#   * proper documentation (comments)
module Delocalize
  class LocalizedDateTimeParser
    class << self
      def parse(datetime, type, defaults = {})
        return unless datetime
        return datetime if datetime.respond_to?(:strftime) # already a Date/Time object -> no need to parse it

        today = Date.current
        defaults = {:year => today.year, :mon => today.mon, :mday => today.mday}.update(defaults)
        translate_month_and_day_names(datetime)
        input_formats(type).each do |original_format|
          next unless datetime =~ /^#{apply_regex(original_format)}$/

          parsed =  DateTime._strptime(datetime, original_format)
          parsed.reverse_merge!(defaults)
          datetime = Time.zone.local(*parsed.values_at(:year, :mon, :mday, :hour, :min, :sec))
          return Date == type ? datetime.to_date : datetime
        end
        default_parse(datetime, type, defaults)
      end

      private
      def default_parse(datetime, type, defaults)
        return if datetime.blank?
        begin
          parsed = Date._parse(datetime)
          return if parsed.empty? # the datetime value is invalid
          # set default year, month and day if not found
          parsed.reverse_merge!(defaults)
          datetime = Time.zone.local(*parsed.values_at(:year, :mon, :mday, :hour, :min, :sec))
          Date == type ? datetime.to_date : datetime
        rescue
          datetime
        end
      end

      def translate_month_and_day_names(datetime)
        translated = I18n.t([:month_names, :abbr_month_names, :day_names, :abbr_day_names], :scope => :date).flatten.compact
        original = (Date::MONTHNAMES + Date::ABBR_MONTHNAMES + Date::DAYNAMES + Date::ABBR_DAYNAMES).compact
        translated.each_with_index { |name, i| datetime.gsub!(name, original[i]) }
      end

      def input_formats(type)
        # Date uses date formats, all others use time formats
        type = type == Date ? :date : :time
        (@input_formats ||= {})[type] ||= I18n.t(:"#{type}.formats").slice(*I18n.t(:"#{type}.input.formats")).values
      end

      def apply_regex(format)
        # maybe add other options as well
        format.gsub('%B', "(#{Date::MONTHNAMES.compact.join('|')})"). # long month name
          gsub('%b', "(#{Date::ABBR_MONTHNAMES.compact.join('|')})"). # short month name
          gsub('%m', "(\\d{2})").                                     # numeric month
          gsub('%A', "(#{Date::DAYNAMES.join('|')})").                # full day name
          gsub('%a', "(#{Date::ABBR_DAYNAMES.join('|')})").           # short day name
          gsub('%Y', "(\\d{4})").                                     # long year
          gsub('%y', "(\\d{2})").                                     # short year
          gsub('%e', "(\\s?\\d{1,2})").                               # short day
          gsub('%d', "(\\d{2})").                                     # full day
          gsub('%H', "(\\d{2})").                                     # hour (24)
          gsub('%M', "(\\d{2})").                                     # minute
          gsub('%S', "(\\d{2})")                                      # second
      end
    end
  end
end
