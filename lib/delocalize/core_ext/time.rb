require 'delocalize/localized_date_time_parser'

Time.class_eval do
  class << self
    def parse_localized(time)
      Delocalize::LocalizedDateTimeParser.parse(time, self)
    end
  end
end