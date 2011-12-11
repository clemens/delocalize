require 'action_view'

# TODO: also override other methods like to_check_box_tag since they might contain numeric values?
# ActionView needs some patching too

ActionView::Helpers::InstanceTag.class_eval do
  include ActionView::Helpers::NumberHelper

  alias original_to_input_field_tag to_input_field_tag
  def to_input_field_tag(field_type, options = {})
    options.symbolize_keys!
    # numbers and dates/times should be localized unless value is already defined
    if object && options[:value].blank? && object.respond_to?(:column_for_attribute) && column = object.column_for_attribute(method_name)
      # a little verbose
      if column.number? || column.date? || column.time?
        value = object.send(method_name)

        if column.number?
          number_options = I18n.t(:'number.format')
          separator = options.delete(:separator) || number_options[:separator]
          delimiter = options.delete(:delimiter) || number_options[:delimiter]
          precision = options.delete(:precision) || number_options[:precision]
          opts = { :separator => separator, :delimiter => delimiter, :precision => precision }
          # integers don't need a precision
          opts.merge!(:precision => 0) if column.type == :integer

          hidden_for_integer = field_type == 'hidden' && column.type == :integer

          # checks for :not_a_number numericality errors.
          has_numericality_errors_that_dont_allow_formatting = object.respond_to?(:errors) && begin
            i18n_scope = :"#{object.class.i18n_scope}.errors" # :"activerecord.errors"
            model_name = object.class.to_s.underscore # :product
            errors_for_method = Array(object.errors[method_name])

            # Searches through the following keys for any error that tell that a :not_a_number error is present
            # * activerecord.errors.models.product.attributes.price.not_a_number
            # * activerecord.errors.models.product.not_a_number
            # * activerecord.errors.messages.not_a_number
            ["models.#{model_name}.attributes.#{method_name}.not_a_number",
            "models.#{model_name}.not_a_number",
            "messages.not_a_number"].any? do |i18n_key|
              error_message = I18n.t!(i18n_key, :scope => i18n_scope, :default => 'is not a number')
              errors_for_method.try(:include?, error_message)
            end
          end

          # the number will be formatted only if it has no numericality errors
          # we don't format integer hidden fields because this breaks nested_attributes
          unless has_numericality_errors_that_dont_allow_formatting || hidden_for_integer
            options[:value] = number_with_precision(value, opts)
          end

        elsif column.date? || column.time?
          options[:value] = value ? I18n.l(value, :format => options.delete(:format)) : nil
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

