require 'test_helper'

describe Delocalize::LocalizedNumericParser do
  before do
    @parser = Delocalize::LocalizedNumericParser
  end

  it "parses a number from a string" do
    @parser.parse('1.299,99').must_equal '1299.99'
  end

  it "parses a negative number from a string" do
    @parser.parse('-1.299,99').must_equal '-1299.99'
  end

  it "parses an integer from a string" do
    @parser.parse('1.299').must_equal '1299'
  end

  it "parses a negative integer from a string" do
    @parser.parse('-1.299').must_equal '-1299'
  end

  it "doesn't change a number if it's already a numeric type" do
    @parser.parse(1299.99).must_equal 1299.99
    @parser.parse(-1299.99).must_equal -1299.99
    @parser.parse(1299).must_equal 1299
    @parser.parse(-1299).must_equal -1299
  end
end
