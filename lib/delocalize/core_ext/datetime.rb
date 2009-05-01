require 'delocalize/localized_date_time_parser'

DateTime.class_eval do
  class << self
    def parse_localized(datetime)
      Delocalize::LocalizedDateTimeParser.parse(datetime, self)
    end
  end
end