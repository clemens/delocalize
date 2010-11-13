require 'delocalize/localized_date_time_parser'

Time.class_eval do
  class << self
    def parse_localized(time, defaults={})
      Delocalize::LocalizedDateTimeParser.parse(time, self, defaults)
    end
  end
end