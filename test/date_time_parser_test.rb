# encoding: utf-8

require 'test_helper'
require 'active_support/time'

describe Delocalize::Parsers::DateTime do
  before do
    I18n.locale = I18n.default_locale
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @time_parser = Delocalize::Parsers::DateTime.new(Time)
    @date_parser = Delocalize::Parsers::DateTime.new(Date)
  end

  after do
    Timecop.return
  end

  it "parses a date/time using default parsing" do
    I18n.locale = :en # force default parsing since we don't have a locale file for en

    date = Date.civil(2009, 2, 28)
    time = Time.zone.local(2009, 2, 28, 12, 30, 45)
    @date_parser.parse('2009-02-28').must_equal date
    @time_parser.parse('2009-02-28 12:30:45').must_equal time
  end

  it "doesn't parse date/time-like objects" do
    date = Date.civil(2009, 10, 19)
    time = Time.zone.local(2009, 3, 1, 12, 0, 0)

    @date_parser.parse(date).must_equal date
    @time_parser.parse(time).must_equal time
  end

  # date
  it "parses a date from a string" do
    date = Date.civil(2009, 10, 19)
    @date_parser.parse('19. Oktober 2009').must_equal date
    @date_parser.parse('19.10.2009').must_equal date
  end

  it "parses a date without a year from a string, defaulting to the current year" do
    date = Date.civil(Date.today.year, 10, 19)
    @date_parser.parse('19. Okt.').must_equal date
    @date_parser.parse('19.10.').must_equal date
  end

  it "fails for an invalid date (same behavior as without delocalize)" do
    must_raise_invalid_date { @date_parser.parse('29. Februar 2009') }
  end

  it "rejects invalid dates when using default parsing (Ruby default behavior)" do
    I18n.locale = :en # force default parsing since we don't have a locale file for en

    must_raise_invalid_date { @date_parser.parse('32.10.2009') }
  end


  it "rejects 29th February in a non leap year when using default parsing (Ruby default behavior)" do
    I18n.locale = :en # force default parsing since we don't have a locale file for en

    must_raise_invalid_date { @date_parser.parse('29.02.2009') }
  end

  # datetime
  it "parses a datetime from a string" do
    time = Time.zone.local(2009, 3, 1, 12, 0, 0)
    @time_parser.parse('Sonntag, 1. März 2009, 12:00 Uhr').must_equal time
    @time_parser.parse('1. März 2009, 12:00 Uhr').must_equal time
  end

  it "parses a datetime without a year from a string, defaulting to the current year" do
    time = Time.zone.local(Time.now.year, 3, 1, 12, 0, 0)
    @time_parser.parse('1. März, 12:00 Uhr').must_equal time
  end

  it "doesn't fail for an invalid datetime (same behavior as without delocalize)" do
    time = Time.zone.local(2009, 3, 1, 12, 0)
    @time_parser.parse('29. Februar 2009, 12:00 Uhr').must_equal time
  end

  it "shifts invalid dates to the next month when using default parse (mimicking Ruby's default behavior)" do
    I18n.locale = :en # force default parsing since we don't have a locale file for en

    time = Time.zone.local(2009, 5, 1, 12, 0, 0)
    @time_parser.parse('31.04.2009 12:00').must_equal time
  end

  it "shifts 29th February to 1st March in a non leap year when using default parse (mimicking Ruby's default behavior)" do
    I18n.locale = :en # force default parsing since we don't have a locale file for en

    time = Time.zone.local(2009, 3, 1, 12, 0, 0)
    @time_parser.parse('29.02.2009 12:00').must_equal time
  end

  # time
  it "parses a time from a string, defaulting to the current day" do
    Timecop.freeze(Time.zone.local(2009, 3, 1, 12, 0, 0)) # prevent DST issues
    time = Time.zone.local(2009, 3, 1, 9, 0, 0, 0)
    @time_parser.parse('9:00 Uhr').must_equal time
  end

  def must_raise_invalid_date
    begin
      yield
    rescue => ex
      ex.message.must_equal 'invalid date'
    end
  end
end
