# encoding: utf-8

require 'i18n'
require 'active_support/all'
require 'timecop'

require 'delocalize/localized_numeric_parser'

class LocalizedNumericParserTest < ActiveSupport::TestCase
  setup do
    I18n.backend.store_translations :de, {
      :number => {
        :format => {
          :precision => 2,
          :separator => ',',
          :delimiter => '.'
        }
      }
    }
    I18n.locale = :de
  end

  test "parses a regular integer" do
    number = Delocalize::LocalizedNumericParser.parse('1337')
    assert_equal '1337', number
  end

  test "parses an integer with thousands delimiter" do
    number = Delocalize::LocalizedNumericParser.parse('1.337')
    assert_equal '1337', number
  end

  test "parses an integer with decimal separator" do
    number = Delocalize::LocalizedNumericParser.parse('1,337')
    assert_equal '1.337', number
  end

  test "parses an integer with thousands delimiter and decimal separator" do
    number = Delocalize::LocalizedNumericParser.parse('1.337,1337')
    assert_equal '1337.1337', number
  end
end
