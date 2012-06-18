require_relative 'isolated_test_helper'

require 'delocalize/delocalizable'

class DelocalizableClass
  include Delocalize::Delocalizable
end

class DelocalizableTest < ActiveSupport::TestCase
  setup do
    DelocalizableClass.delocalizable_fields = []
    DelocalizableClass.delocalize_conversions = {}
  end

  test "stores the delocalizable fields" do
    DelocalizableClass.delocalize :foo => :number, :bar => {:type => :time}
    assert_equal [:foo, :bar], DelocalizableClass.delocalizable_fields
  end

  test "stores the delocalizable fields as symbols" do
    DelocalizableClass.delocalize 'foo' => 'number', 'bar' => {:type => 'time'}
    assert_equal [:foo, :bar], DelocalizableClass.delocalizable_fields
  end

  test "stores the delocalizable fields without overriding existing ones" do
    DelocalizableClass.delocalize :foo => :number, :bar => {:type => :time}
    DelocalizableClass.delocalize :baz => :date
    assert_equal [:foo, :bar, :baz], DelocalizableClass.delocalizable_fields
  end

  test "stores the delocalizable fields without duplicates" do
    DelocalizableClass.delocalize :foo => :number, :bar => {:type => :time}
    DelocalizableClass.delocalize :foo => :date
    assert_equal [:foo, :bar], DelocalizableClass.delocalizable_fields
  end

  test "stores conversions" do
    DelocalizableClass.delocalize :foo => :number, :bar => {:type => :time}
    assert_equal :number, DelocalizableClass.delocalize_conversions[:foo]
    assert_equal :time, DelocalizableClass.delocalize_conversions[:bar]
  end

  test "stores conversions as symbols" do
    DelocalizableClass.delocalize 'foo' => 'number', 'bar' => {:type => 'time'}
    assert_equal :number, DelocalizableClass.delocalize_conversions[:foo]
    assert_equal :time, DelocalizableClass.delocalize_conversions[:bar]
  end

  test "stores conversions and overrides previous settings" do
    DelocalizableClass.delocalize :foo => :number
    DelocalizableClass.delocalize :foo => :date
    assert_equal :date, DelocalizableClass.delocalize_conversions[:foo]
  end

  test "stores options" do
    DelocalizableClass.delocalize :foo => {:type => :number, :any_option => 23}
    assert_equal({:any_option => 23}, DelocalizableClass.delocalize_options[:foo])
  end

  test "stores options and overrides previous settings" do
    DelocalizableClass.delocalize :foo => {:type => :number, :any_option => 23}
    DelocalizableClass.delocalize :foo => {:type => :date, :other_option => 42}
    assert_equal({:other_option => 42}, DelocalizableClass.delocalize_options[:foo])
  end

  test "defines attribute writers" do
    DelocalizableClass.delocalize :foo => :number, :bar => :time
    instance = DelocalizableClass.new
    assert instance.respond_to?(:foo=)
    assert instance.respond_to?(:bar=)
  end

  test "tells that it is delocalizing" do
    DelocalizableClass.delocalize :foo => :number, :bar => :time
    assert DelocalizableClass.delocalizing?
  end

  test "tells that it is not delocalizing" do
    assert !DelocalizableClass.delocalizing?
  end

  test "tells that it is delocalizing (on an instance)" do
    DelocalizableClass.delocalize :foo => :number, :bar => :time
    assert DelocalizableClass.new.delocalizing?
  end

  test "tells that it is not delocalizing (on an instance)" do
    assert !DelocalizableClass.new.delocalizing?
  end

  test "tells that a field is to be delocalized" do
    DelocalizableClass.delocalize :foo => :number
    assert DelocalizableClass.delocalizes?(:foo)
  end

  test "tells that a field is not to be delocalized" do
    DelocalizableClass.delocalize :foo => :number
    assert !DelocalizableClass.delocalizes?(:baz)
  end

  test "tells that a field is to be delocalized (on an instance)" do
    DelocalizableClass.delocalize :foo => :number
    assert DelocalizableClass.new.delocalizes?(:foo)
  end

  test "tells that a field is not to be delocalized (on an instance)" do
    DelocalizableClass.delocalize :foo => :number
    assert !DelocalizableClass.new.delocalizes?(:baz)
  end

  test "tells the delocalize type of a field" do
    DelocalizableClass.delocalize :foo => :number
    assert_equal :number, DelocalizableClass.delocalize_type_for(:foo)
  end

  test "tells the delocalize type of a field (on an instance)" do
    DelocalizableClass.delocalize :foo => :number
    assert_equal :number, DelocalizableClass.new.delocalize_type_for(:foo)
  end
end
