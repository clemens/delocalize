# encoding: utf-8

require 'i18n'
require 'active_support/all'
require 'timecop'

require 'delocalize/localized_date_time_parser'

class LocalizedDateTimeParserTest < ActiveSupport::TestCase
  setup do
    I18n.backend.store_translations :de, {
      :date => {
        :input => {
          :formats => [:long, :short, :default]
        },
        :formats => {
          :default => "%d.%m.%Y",
          :short => "%e. %b",
          :long => "%e. %B %Y",
          :only_day => "%e"
        },
        :day_names => %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag),
        :abbr_day_names => %w(So Mo Di Mi Do Fr Sa),
        :month_names => [nil] + %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember),
        :abbr_month_names => [nil] + %w(Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez)
      },
      :time => {
        :input => {
          :formats => [:long, :medium, :short, :default, :time]
        },
        :formats => {
          :default => "%A, %e. %B %Y, %H:%M Uhr",
          :short => "%e. %B, %H:%M Uhr",
          :medium => "%e. %B %Y, %H:%M Uhr",
          :long => "%A, %e. %B %Y, %H:%M Uhr",
          :time => "%H:%M Uhr"
        },
        :am => 'vormittags',
        :pm => 'nachmittags'
      }
    }
    I18n.locale = :de
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    Timecop.freeze(Time.zone.local(2009, 3, 1, 12, 0))
  end

  test "parses a date" do
    date = Delocalize::LocalizedDateTimeParser.parse('17. Januar 2012', Date)
    assert_equal Date.civil(2012, 1, 17), date
  end

  test "parses a time" do
    time = Delocalize::LocalizedDateTimeParser.parse('17. Januar 2012 21:15', Time)
    assert_equal Time.local(2012, 1, 17, 21, 15), time
  end

  test "parses a datetime" do
    datetime = Delocalize::LocalizedDateTimeParser.parse('17. Januar 2012 21:15', DateTime)
    assert_equal Time.local(2012, 1, 17, 21, 15).to_datetime, datetime
  end

  test "doesn't calculate if given object is already a time-like object" do
    pending
  end
end
