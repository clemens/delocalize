# TODO:
#   * AM/PM calculation
#   * proper documentation (comments)
module Delocalize
  class LocalizedDateTimeParser
    # extend/change this according to your needs by merging your custom regexps
    REGEXPS = {
      '%B' => "(#{Date::MONTHNAMES.compact.join('|')})",      # long month name
      '%b' => "(#{Date::ABBR_MONTHNAMES.compact.join('|')})", # short month name
      '%m' => "(\\d{2})",                                     # numeric month
      '%A' => "(#{Date::DAYNAMES.join('|')})",                # full day name
      '%a' => "(#{Date::ABBR_DAYNAMES.join('|')})",           # short day name
      '%Y' => "(\\d{4})",                                     # long year
      '%y' => "(\\d{2})",                                     # short year
      '%e' => "(\\s\\d|\\d{2})",                              # short day
      '%d' => "(\\d{2})",                                     # full day
      '%H' => "(\\d{2})",                                     # hour (24)
      '%M' => "(\\d{2})",                                     # minute
      '%S' => "(\\d{2})"                                      # second
    }

    class << self
      def parse(datetime, type)
        return unless datetime
        return datetime if datetime.respond_to?(:strftime) # already a Date/Time object -> no need to parse it

        translate_month_and_day_names(datetime)
        input_formats(type).each do |original_format|
          next unless datetime =~ /^#{apply_regex(original_format)}$/

          datetime = DateTime.strptime(datetime, original_format)
          return Date == type ?
            datetime.to_date :
            Time.zone.local(datetime.year, datetime.mon, datetime.mday, datetime.hour, datetime.min, datetime.sec)
        end
        default_parse(datetime, type)
      end

      private
      def default_parse(datetime, type)
        return if datetime.blank?
        begin
          today = Date.current
          parsed = Date._parse(datetime)
          return if parsed.empty? # the datetime value is invalid
          # set default year, month and day if not found
          parsed.reverse_merge!(:year => today.year, :mon => today.mon, :mday => today.mday)
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
        format.gsub(/(#{REGEXPS.keys.join('|')})/) { |s| REGEXPS[$1] }
      end
    end
  end
end
