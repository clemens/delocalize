require 'active_support/all'

require 'delocalize/delocalizable'

class DelocalizableClass
  include Delocalize::Delocalizable
end

class DelocalizableTest < ActiveSupport::TestCase
  setup do
    DelocalizableClass.delocalizable_fields = []
  end

  test "stores the delocalizable fields" do
    DelocalizableClass.delocalize :foo, :bar
    assert_equal [:foo, :bar], DelocalizableClass.delocalizable_fields
  end

  test "stores the delocalizable fields as symbols" do
    DelocalizableClass.delocalize 'foo', 'bar'
    assert_equal [:foo, :bar], DelocalizableClass.delocalizable_fields
  end

  test "stores the delocalizable fields without overriding existing ones" do
    DelocalizableClass.delocalize :foo, :bar
    DelocalizableClass.delocalize :baz
    assert_equal [:foo, :bar, :baz], DelocalizableClass.delocalizable_fields
  end

  test "stores the delocalizable fields without duplicates" do
    DelocalizableClass.delocalize :foo, :foo, :bar
    assert_equal [:foo, :bar], DelocalizableClass.delocalizable_fields
  end

  test "tells that a field is to be delocalized" do
    DelocalizableClass.delocalize :foo, :bar
    assert DelocalizableClass.delocalizes?(:foo)
  end

  test "tells that a field is not to be delocalized" do
    DelocalizableClass.delocalize :foo, :bar
    assert !DelocalizableClass.delocalizes?(:baz)
  end
end
