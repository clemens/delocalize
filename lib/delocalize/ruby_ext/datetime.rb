require 'delocalize/localized_date_time_parser'

DateTime.class_eval do
  class << self
    def parse_localized(datetime, defaults={})
      Delocalize::LocalizedDateTimeParser.parse(datetime, self, defaults)
    end
  end
end