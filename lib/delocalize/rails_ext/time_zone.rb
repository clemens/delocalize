require 'delocalize/localized_date_time_parser'

ActiveSupport::TimeZone.class_eval do
  def parse_localized(time_with_zone, defaults={})
    Delocalize::LocalizedDateTimeParser.parse(time_with_zone, self.class, defaults)
  end
end