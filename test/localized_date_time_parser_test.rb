# encoding: utf-8

require 'test_helper'

describe Delocalize::LocalizedDateTimeParser do
  before do
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @parser = Delocalize::LocalizedDateTimeParser
  end

  after do
    Timecop.return
  end

  # date
  it "parses a date from a string" do
    date = Date.civil(2009, 10, 19)
    @parser.parse('19. Oktober 2009', Date).must_equal date
    @parser.parse('19.10.2009', Date).must_equal date
  end

  # FIXME
  # it "parses a date without a year from a string, defaulting to the current year" do
  #   date = Date.civil(Date.today.year, 10, 19)
  #   @parser.parse('19. Oktober', Date).must_equal date
  #   @parser.parse('19.10.', Date).must_equal date
  # end

  # datetime
  it "parses a datetime from a string" do
    time = Time.zone.local(2009, 3, 1, 12, 0, 0)
    @parser.parse('Sonntag, 1. März 2009, 12:00 Uhr', Time).must_equal time
    @parser.parse('1. März 2009, 12:00 Uhr', Time).must_equal time
  end

  it "parses a datetime without a year from a string, defaulting to the current year" do
    time = Time.zone.local(Time.now.year, 3, 1, 12, 0, 0)
    @parser.parse('1. März, 12:00 Uhr', Time).must_equal time
  end

  # time
  it "parses a time from a string, defaulting to the current day" do
    Timecop.freeze(Time.zone.local(2009, 3, 1, 12, 0, 0)) # prevent DST issues
    time = Time.zone.local(2009, 3, 1, 9, 0, 0, 0)
    @parser.parse('9:00 Uhr', Time).must_equal time
  end

  it "doesn't parse date/time-like objects" do
    date = Date.civil(2009, 10, 19)
    time = Time.zone.local(2009, 3, 1, 12, 0, 0)

    @parser.parse(date, Date).must_equal date
    @parser.parse(time, Time).must_equal time
  end
end
