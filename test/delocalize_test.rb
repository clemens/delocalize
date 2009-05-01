require File.dirname(__FILE__) + '/test_helper'

class DelocalizeTest < ActiveRecord::TestCase
  def setup
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    @product = Product.new
  end

  test "delocalizes localized number" do
    @product.price = '1.299,99'
    assert_equal 1299.99, @product.price
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
end
