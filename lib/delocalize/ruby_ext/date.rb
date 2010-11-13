require 'delocalize/localized_date_time_parser'

Date.class_eval do
  class << self
    def parse_localized(date, defaults={})
      Delocalize::LocalizedDateTimeParser.parse(date, self, defaults)
    end
  end
end