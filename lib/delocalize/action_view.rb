require 'action_view'

ActionView::Helpers::InstanceTag.class_eval do
  include ActionView::Helpers::NumberHelper

  alias original_to_input_field_tag to_input_field_tag
  def to_input_field_tag(field_type, options = {})
    options.symbolize_keys!

    # Return as early as possible even though the call is duplicate
    #
    # We can return in the following cases:
    # - delocalization is disabled
    # - no object is present
    # - a value is present
    # - the field type is hidden
    # - the field has errors
    # - the object does not delocalize at all
    # - the object does not delocalize the given field
    do_return = Delocalize.disabled? ||
                object.blank? ||
                options[:value].present? ||
                field_type == 'hidden' ||
                (object.respond_to?(:errors) && object.errors[method_name].any?) ||
                !(object.respond_to?(:delocalizes?) && object.delocalizes?(method_name))

    return original_to_input_field_tag(field_type, options) if do_return

    value = object.send(method_name)
    type = object.delocalize_type_for(method_name)

    case type
    when :number
      options[:value] = number_with_precision(value, object.delocalize_options_for(method_name))
    when :date, :time
      localize_options = object.delocalize_options_for(method_name).dup
      localize_options[:format] ||= :default
      localize_options[:format] = options.delete(:format) if options[:format]
      options[:value] = value ? I18n.l(value, localize_options) : nil
    end

    original_to_input_field_tag(field_type, options)
  end
end
