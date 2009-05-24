# TODO: also override other methods like to_check_box_tag since they might contain numeric values?
# ActionView needs some patching too

ActionView::Helpers::InstanceTag.class_eval do
  include ActionView::Helpers::NumberHelper

  alias original_to_input_field_tag to_input_field_tag
  def to_input_field_tag(field_type, options = {})
    # numbers and dates/times should be localized
    if column = object.column_for_attribute(method_name)
      # a little verbose
      if column.number? || column.date? || column.time?
        options.symbolize_keys!
        value = object.send(method_name)

        if column.number?
          number_options = I18n.t(:'number.format')
          separator = options.delete(:separator) || number_options[:separator]
          delimiter = options.delete(:delimiter) || number_options[:delimiter]
          precision = options.delete(:precision) || number_options[:precision]
          options[:value] = number_with_precision(value, :separator => separator, :delimiter => delimiter, :precision => precision)
        elsif column.date? || column.time?
          options[:value] = I18n.l(value, :format => options.delete(:format))
        end
      end
    end

    original_to_input_field_tag(field_type, options)
  end
end

# TODO: does it make sense to also override FormTagHelper methods?
# ActionView::Helpers::FormTagHelper.class_eval do
#   include ActionView::Helpers::NumberHelper
# 
#   alias original_text_field_tag text_field_tag
#   def text_field_tag(name, value = nil, options = {})
#     value = options.delete(:value) if options.key?(:value)
#     if value.is_a?(Numeric)
#       value = number_with_delimiter(value)
#     end
#     original_text_field_tag(name, value, options)
#   end
# end