require 'action_view'

# TODO: also override other methods like to_check_box_tag since they might contain numeric values?
# ActionView needs some patching too

ActionView::Helpers::Tags::TextField.class_eval do
  include ActionView::Helpers::NumberHelper

  def render_with_localization
    if object && (@options[:value].blank? || !@options[:value].is_a?(String)) && object.respond_to?(:column_for_attribute) && column = object.column_for_attribute(@method_name)
      value = @options[:value] || object.send(@method_name)

      if column.number?
        number_options = I18n.t(:'number.format')
        separator = @options.delete(:separator) || number_options[:separator]
        delimiter = @options.delete(:delimiter) || number_options[:delimiter]
        precision = @options.delete(:precision) || number_options[:precision]
        opts = { :separator => separator, :delimiter => delimiter, :precision => precision }
        # integers don't need a precision
        opts.merge!(:precision => 0) if column.type == :integer

        hidden_for_integer = field_type == 'hidden' && column.type == :integer

        # the number will be formatted only if it has no numericality errors
        if object.respond_to?(:errors) && !Array(object.errors[@method_name]).try(:include?, 'is not a number')
          # we don't format integer hidden fields because this breaks nested_attributes
          @options[:value] = number_with_precision(value, opts) unless hidden_for_integer
        end
      elsif column.date? || column.time?
        @options[:value] = value ? I18n.l(value, :format => @options.delete(:format)) : nil
      end
    end

    render_without_localization
  end

  alias_method_chain :render, :localization
end
