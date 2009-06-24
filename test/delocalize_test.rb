require File.dirname(__FILE__) + '/test_helper'

class DelocalizeActiveRecordTest < ActiveRecord::TestCase
  def setup
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @product = Product.new
  end

  test "delocalizes localized number" do
    @product.price = '1.299,99'
    assert_equal 1299.99, @product.price

    @product.price = '-1.299,99'
    assert_equal -1299.99, @product.price
  end

  test "delocalizes localized date" do
    date = Date.civil(2009, 10, 19)

    @product.released_on = '19. Oktober 2009'
    assert_equal date, @product.released_on

    @product.released_on = '19. Okt'
    assert_equal date, @product.released_on

    @product.released_on = '19.10.2009'
    assert_equal date, @product.released_on
  end

  test "delocalizes localized datetime" do
    time = Time.local(2009, 3, 1, 12, 0, 0)

    @product.published_at = 'Sonntag, 1. März 2009, 12:00 Uhr'
    assert_equal time, @product.published_at

    @product.published_at = '1. März 2009, 12:00 Uhr'
    assert_equal time, @product.published_at

    @product.published_at = '1. März, 12:00 Uhr'
    assert_equal time, @product.published_at
  end

  test "delocalizes localized time" do
    now = Time.current
    time = Time.local(now.year, now.month, now.day, 9, 0, 0)
    @product.cant_think_of_a_sensible_time_field = '09:00 Uhr'
    assert_equal time, @product.cant_think_of_a_sensible_time_field
  end

  test "uses default parse if format isn't found" do
    date = Date.civil(2009, 10, 19)

    @product.released_on = '2009/10/19'
    assert_equal date, @product.released_on

    time = Time.local(2009, 3, 1, 12, 0, 0)
    @product.published_at = '2009/03/01 12:00'
    assert_equal time, @product.published_at

    now = Time.current
    time = Time.local(now.year, now.month, now.day, 9, 0, 0)
    @product.cant_think_of_a_sensible_time_field = '09:00'
    assert_equal time, @product.cant_think_of_a_sensible_time_field
  end

  test "should return nil if the input is empty or invalid" do
    @product.released_on = ""
    assert_nil @product.released_on

    @product.released_on = "aa"
    assert_nil @product.released_on
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
    assert_dom_equal '<input id="product_price" name="product[price]" size="30" type="text" value="1.299,90" />',
      text_field(:product, :price)
  end

  test "shows text field using formatted number with options" do
    @product.price = 1299.995
    assert_dom_equal '<input id="product_price" name="product[price]" size="30" type="text" value="1,299.995" />',
      text_field(:product, :price, :precision => 3, :delimiter => ',', :separator => '.')
  end

  test "shows text field using formatted date" do
    @product.released_on = Date.civil(2009, 10, 19)
    assert_dom_equal '<input id="product_released_on" name="product[released_on]" size="30" type="text" value="19.10.2009" />',
      text_field(:product, :released_on)
  end

  test "shows text field using formatted date and time" do
    @product.published_at = Time.local(2009, 3, 1, 12, 0, 0)
    # careful - leading whitespace with %e
    assert_dom_equal '<input id="product_published_at" name="product[published_at]" size="30" type="text" value="Sonntag,  1. März 2009, 12:00 Uhr" />',
      text_field(:product, :published_at)
  end

  test "shows text field using formatted date with format" do
    @product.released_on = Date.civil(2009, 10, 19)
    assert_dom_equal '<input id="product_released_on" name="product[released_on]" size="30" type="text" value="19. Oktober 2009" />',
      text_field(:product, :released_on, :format => :long)
  end

  test "shows text field using formatted date and time with format" do
    @product.published_at = Time.local(2009, 3, 1, 12, 0, 0)
    # careful - leading whitespace with %e
    assert_dom_equal '<input id="product_published_at" name="product[published_at]" size="30" type="text" value=" 1. März, 12:00 Uhr" />',
      text_field(:product, :published_at, :format => :short)
  end

  test "shows text field using formatted time with format" do
    @product.cant_think_of_a_sensible_time_field = Time.local(2009, 3, 1, 9, 0, 0)
    assert_dom_equal '<input id="product_cant_think_of_a_sensible_time_field" name="product[cant_think_of_a_sensible_time_field]" size="30" type="text" value="09:00 Uhr" />',
      text_field(:product, :cant_think_of_a_sensible_time_field, :format => :time)
  end

  test "doesn't raise an exception when object is nil" do
    assert_nothing_raised {
      text_field(:not_here, :a_text_field)
    }
  end
end
