# encoding: utf-8

require 'test_helper'
require 'active_record/test_case'
require 'action_view/test_case'

class DelocalizeActiveRecordTest < ActiveRecord::TestCase
  def setup
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    Timecop.freeze(Time.zone.local(2009, 3, 1, 12, 0))
    @product = Product.new
  end

  def teardown
    Timecop.return
  end

  test "delocalizes localized number" do
    @product.price = '1.299,99'
    assert_equal 1299.99, @product.price

    @product.price = '-1.299,99'
    assert_equal -1299.99, @product.price
  end

  test "delocalizes localized date with year" do
    date = Date.civil(2009, 10, 19)

    @product.released_on = '19. Oktober 2009'
    assert_equal date, @product.released_on

    @product.released_on = '19.10.2009'
    assert_equal date, @product.released_on
  end

  test "delocalizes localized date with year even if locale changes" do
    date = Date.civil(2009, 10, 19)

    @product.released_on = '19. Oktober 2009'
    assert_equal date, @product.released_on

    I18n.with_locale :tt do
      @product.released_on = '10|11|2009'
      date = Date.civil(2009, 11, 10)
      assert_equal date, @product.released_on
    end
  end

  test "delocalizes localized date without year" do
    date = Date.civil(Date.today.year, 10, 19)

    @product.released_on = '19. Okt'
    assert_equal date, @product.released_on
  end

  test "delocalizes localized datetime with year" do
    time = Time.zone.local(2009, 3, 1, 12, 0, 0)

    @product.published_at = 'Sonntag, 1. März 2009, 12:00 Uhr'
    assert_equal time, @product.published_at

    @product.published_at = '1. März 2009, 12:00 Uhr'
    assert_equal time, @product.published_at
  end

  test "delocalizes with fallback locale" do
    I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
    I18n.fallbacks[:xx] = [:xx, :tt]

    I18n.with_locale :xx do
      @product.released_on = '10|11|2009'
      date = Date.civil(2009, 11, 10)
      assert_equal date, @product.released_on
    end
  end

  test "delocalizes localized datetime without year" do
    time = Time.zone.local(Date.today.year, 3, 1, 12, 0, 0)

    @product.published_at = '1. März, 12:00 Uhr'
    assert_equal time, @product.published_at
  end

  # TODO can I somehow do this smarter? or should I use another zone w/o DST?
  if Time.current.dst?
    test "delocalizes localized time (DST)" do
      now = Date.today
      time = Time.zone.local(now.year, now.month, now.day, 9, 0, 0)
      @product.cant_think_of_a_sensible_time_field = '09:00 Uhr'
      assert_equal time, @product.cant_think_of_a_sensible_time_field
    end
  else
    test "delocalizes localized time (non-DST)" do
      now = Date.today
      time = Time.zone.local(now.year, now.month, now.day, 8, 0, 0)
      @product.cant_think_of_a_sensible_time_field = '08:00 Uhr'
      assert_equal time, @product.cant_think_of_a_sensible_time_field
    end
  end

  test "invalid dates should be delocalized to nil" do
    date = '32. Oktober 2009'
    @product.released_on = date
    assert_equal nil, @product.released_on
    assert_equal date, @product.released_on_before_type_cast
  end

  test "uses default parse if format isn't found (non-DST)" do
    date = Date.civil(2009, 10, 19)

    @product.released_on = '2009/10/19'
    assert_equal date, @product.released_on

    time = Time.zone.local(2009, 3, 1, 12, 0, 0)
    @product.published_at = '2009/03/01 12:00'
    assert_equal time, @product.published_at

    now = Time.current
    time = Time.zone.local(now.year, now.month, now.day, 8, 0, 0)
    @product.cant_think_of_a_sensible_time_field = '08:00'
    assert_equal time, @product.cant_think_of_a_sensible_time_field
  end

  test "should return nil if the input is empty or invalid" do
    @product.released_on = ""
    assert_nil @product.released_on

    @product.released_on = "aa"
    assert_nil @product.released_on
  end

  test "doesn't raise when attribute is nil" do
    assert_nothing_raised {
      @product.price = nil
      @product.released_on = nil
      @product.published_at = nil
      @product.cant_think_of_a_sensible_time_field = nil
    }
  end

  test "uses default formats if enable_delocalization is false" do
    I18n.enable_delocalization = false

    @product.price = '1299.99'
    assert_equal 1299.99, @product.price

    @product.price = '-1299.99'
    assert_equal -1299.99, @product.price
  end

  test "uses default formats if called with with_delocalization_disabled" do
    I18n.with_delocalization_disabled do
      @product.price = '1299.99'
      assert_equal 1299.99, @product.price

      @product.price = '-1299.99'
      assert_equal -1299.99, @product.price
    end
  end

  test "uses localized parsing if called with with_delocalization_enabled" do
    I18n.with_delocalization_enabled do
      @product.price = '1.299,99'
      assert_equal 1299.99, @product.price

      @product.price = '-1.299,99'
      assert_equal -1299.99, @product.price
    end
  end

  test "dirty attributes must detect changes in decimal columns" do
    @product.price = 10
    @product.save
    @product.price = "10,34"
    assert @product.price_changed?
  end

  test "dirty attributes must detect changes in float columns" do
    @product.weight = 10
    @product.save
    @product.weight = "10,34"
    assert @product.weight_changed?
  end

  test "attributes that didn't change shouldn't be marked dirty" do
    @product.name = "Good cookies, Really good"
    @product.save
    @product.name = "Good cookies, Really good"
    assert !@product.name_changed?
  end

  test "should remember the value before type cast" do
    @product.price = "asd"
    assert_equal @product.price, 0
    assert_equal @product.price_before_type_cast, "asd"
  end

  test 'it should gsub only whole translated words and not mess up the original string' do
    orig_march = I18n.t('date.month_names')[3]
    orig_monday = I18n.t('date.abbr_day_names')[1]

    #Simulate Dutch
    I18n.t('date.month_names')[3] = 'Maart'
    I18n.t('date.abbr_day_names')[1] = 'Ma'

    subject = '30 Maart 2011'
    Delocalize::LocalizedDateTimeParser.send(:translate_month_and_day_names, subject)

    assert_equal subject, '30 March 2011'

    I18n.t('date.month_names')[3] = orig_march
    I18n.t('date.abbr_day_names')[1] = orig_monday
  end
end

class DelocalizeActionViewTest < ActionView::TestCase
  include ActionView::Helpers::FormHelper

  def setup
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @product = Product.new
  end

  test "shows text field using formatted number" do
    @product.price = 1299.9
    assert_dom_equal '<input id="product_price" name="product[price]" type="text" value="1.299,90" />',
      text_field(:product, :price)
  end

  test "shows text field using formatted number with options" do
    @product.price = 1299.995
    assert_dom_equal '<input id="product_price" name="product[price]" type="text" value="1,299.995" />',
      text_field(:product, :price, :precision => 3, :delimiter => ',', :separator => '.')
  end

  test "shows text field using formatted number without precision if column is an integer" do
    @product.times_sold = 20
    assert_dom_equal '<input id="product_times_sold" name="product[times_sold]" type="text" value="20" />',
      text_field(:product, :times_sold)

    @product.times_sold = 2000
    assert_dom_equal '<input id="product_times_sold" name="product[times_sold]" type="text" value="2.000" />',
      text_field(:product, :times_sold)
  end

  test "shows text field using formatted date" do
    @product.released_on = Date.civil(2009, 10, 19)
    assert_dom_equal '<input id="product_released_on" name="product[released_on]" type="text" value="19.10.2009" />',
      text_field(:product, :released_on)
  end

  test "shows text field using formatted date and time" do
    @product.published_at = Time.zone.local(2009, 3, 1, 12, 0, 0)
    # careful - leading whitespace with %e
    assert_dom_equal '<input id="product_published_at" name="product[published_at]" type="text" value="Sonntag,  1. März 2009, 12:00 Uhr" />',
      text_field(:product, :published_at)
  end

  test "shows text field using formatted date with format" do
    @product.released_on = Date.civil(2009, 10, 19)
    assert_dom_equal '<input id="product_released_on" name="product[released_on]" type="text" value="19. Oktober 2009" />',
      text_field(:product, :released_on, :format => :long)
  end

  test "shows text field using formatted date and time with format" do
    @product.published_at = Time.zone.local(2009, 3, 1, 12, 0, 0)
    # careful - leading whitespace with %e
    assert_dom_equal '<input id="product_published_at" name="product[published_at]" type="text" value=" 1. März, 12:00 Uhr" />',
      text_field(:product, :published_at, :format => :short)
  end

  test "shows text field using formatted time with format" do
    @product.cant_think_of_a_sensible_time_field = Time.zone.local(2009, 3, 1, 9, 0, 0)
    assert_dom_equal '<input id="product_cant_think_of_a_sensible_time_field" name="product[cant_think_of_a_sensible_time_field]" type="text" value="09:00 Uhr" />',
      text_field(:product, :cant_think_of_a_sensible_time_field, :format => :time)
  end

  test "integer hidden fields shouldn't be formatted" do
    @product.times_sold = 1000
    assert_dom_equal '<input id="product_times_sold" name="product[times_sold]" type="hidden" value="1000" />',
      hidden_field(:product, :times_sold)
  end

  test "doesn't raise an exception when object is nil" do
    assert_nothing_raised {
      text_field(:not_here, :a_text_field)
    }
  end

  test "doesn't raise for nil Date/Time" do
    @product.published_at, @product.released_on, @product.cant_think_of_a_sensible_time_field = nil
    assert_nothing_raised {
      text_field(:product, :published_at)
      text_field(:product, :released_on)
      text_field(:product, :cant_think_of_a_sensible_time_field)
    }
  end

  test "delocalizes a given non-string :value" do
    @product.price = 1299.9
    assert_dom_equal '<input id="product_price" name="product[price]" type="text" value="1.499,90" />',
      text_field(:product, :price, :value => 1499.90)
  end

  test "doesn't override given string :value" do
    @product.price = 1299.9
    assert_dom_equal '<input id="product_price" name="product[price]" type="text" value="1.499,90" />',
      text_field(:product, :price, :value => "1.499,90")
  end

  test "doesn't convert the value if field has numericality errors" do
    @product = ProductWithValidation.new(:price => 'this is not a number')
    @product.valid?
    assert_dom_equal %(<div class="field_with_errors"><input id="product_price" name="product[price]" type="text" value="this is not a number" /></div>),
      text_field(:product, :price)
  end

  test "should convert the value if field have non-numericality errors, but have other errors, e.g. business rules" do
    @product = ProductWithBusinessValidation.new(:price => '1.337,66')
    @product.valid?
    assert_dom_equal %(<div class="field_with_errors"><input id="product_price" name="product[price]" type="text" value="1.337,66" /></div>),
      text_field(:product, :price)
  end

  test "doesn't raise an exception when object isn't an ActiveReccord" do
    @product = NonArProduct.new
    assert_nothing_raised {
      text_field(:product, :name)
      text_field(:product, :times_sold)
      text_field(:product, :published_at)
      text_field(:product, :released_on)
      text_field(:product, :cant_think_of_a_sensible_time_field)
      text_field(:product, :price, :value => "1.499,90")
    }
  end

  test "formats field with default value correctly" do
    assert_dom_equal '<input id="product_some_value_with_default" name="product[some_value_with_default]" type="text" value="0,00" />',
      text_field(:product, :some_value_with_default)
  end
end

