require_relative 'isolated_test_helper'

require 'delocalize/delocalizable'

class DelocalizableTest < ActiveSupport::TestCase
  setup do
    # Make sure we use a new, clean class for every test
    @delocalizable_class = Class.new do
      include Delocalize::Delocalizable
    end
  end

  test "stores the delocalizable fields" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    assert_equal [:foo, :bar], @delocalizable_class.delocalizable_fields
  end

  test "stores the delocalizable fields as symbols" do
    @delocalizable_class.delocalize 'foo' => 'number', 'bar' => 'time'
    assert_equal [:foo, :bar], @delocalizable_class.delocalizable_fields
  end

  test "stores the delocalizable fields without overriding existing ones" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    @delocalizable_class.delocalize :baz => :date
    assert_equal [:foo, :bar, :baz], @delocalizable_class.delocalizable_fields
  end

  test "stores the delocalizable fields without duplicates" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    @delocalizable_class.delocalize :foo => :date
    assert_equal [:foo, :bar], @delocalizable_class.delocalizable_fields
  end

  test "inheriting delocalizable fields works correctly" do
    @delocalizable_class.delocalize :base => :number
    foo_class = Class.new(@delocalizable_class) { delocalize :foo => :number }
    bar_class = Class.new(@delocalizable_class) { delocalize :bar => :number }
    assert_equal [:base], @delocalizable_class.delocalizable_fields
    assert_equal [:base, :foo], foo_class.delocalizable_fields
    assert_equal [:base, :bar], bar_class.delocalizable_fields
  end

  test "stores conversions" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    assert_equal :number, @delocalizable_class.delocalize_conversions[:foo]
    assert_equal :time, @delocalizable_class.delocalize_conversions[:bar]
  end

  test "stores conversions as symbols" do
    @delocalizable_class.delocalize 'foo' => 'number', 'bar' => 'time'
    assert_equal :number, @delocalizable_class.delocalize_conversions[:foo]
    assert_equal :time, @delocalizable_class.delocalize_conversions[:bar]
  end

  test "stores conversions and overrides previous settings" do
    @delocalizable_class.delocalize :foo => :number
    @delocalizable_class.delocalize :foo => :date
    assert_equal :date, @delocalizable_class.delocalize_conversions[:foo]
  end

  test "inheriting conversions works correctly" do
    @delocalizable_class.delocalize :foo => :number
    foo_class = Class.new(@delocalizable_class) { delocalize :foo => :date }
    bar_class = Class.new(@delocalizable_class) { delocalize :bar => :time }
    assert_equal({:foo => :number}, @delocalizable_class.delocalize_conversions)
    assert_equal({:foo => :date}, foo_class.delocalize_conversions)
    assert_equal({:foo => :number, :bar => :time}, bar_class.delocalize_conversions)
  end

  test "defines attribute writers" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    instance = @delocalizable_class.new
    assert instance.respond_to?(:foo=)
    assert instance.respond_to?(:bar=)
  end

  test "tells that it is delocalizing" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    assert @delocalizable_class.delocalizing?
  end

  test "tells that it is not delocalizing" do
    assert !@delocalizable_class.delocalizing?
  end

  test "tells that it is delocalizing (on an instance)" do
    @delocalizable_class.delocalize :foo => :number, :bar => :time
    assert @delocalizable_class.new.delocalizing?
  end

  test "tells that it is not delocalizing (on an instance)" do
    assert !@delocalizable_class.new.delocalizing?
  end

  test "tells that a field is to be delocalized" do
    @delocalizable_class.delocalize :foo => :number
    assert @delocalizable_class.delocalizes?(:foo)
  end

  test "tells that a field is not to be delocalized" do
    @delocalizable_class.delocalize :foo => :number
    assert !@delocalizable_class.delocalizes?(:baz)
  end

  test "tells that a field is to be delocalized (on an instance)" do
    @delocalizable_class.delocalize :foo => :number
    assert @delocalizable_class.new.delocalizes?(:foo)
  end

  test "tells that a field is not to be delocalized (on an instance)" do
    @delocalizable_class.delocalize :foo => :number
    assert !@delocalizable_class.new.delocalizes?(:baz)
  end

  test "tells the delocalize type of a field" do
    @delocalizable_class.delocalize :foo => :number
    assert_equal :number, @delocalizable_class.delocalize_type_for(:foo)
  end

  test "tells the delocalize type of a field (on an instance)" do
    @delocalizable_class.delocalize :foo => :number
    assert_equal :number, @delocalizable_class.new.delocalize_type_for(:foo)
  end
end
