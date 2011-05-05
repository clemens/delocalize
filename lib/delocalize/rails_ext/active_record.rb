require 'active_record/connection_adapters/abstract/schema_definitions'
begin
  require 'active_record/connection_adapters/column'
rescue LoadError
  # Not Rails 3.1, it seems
end

# let's hack into ActiveRecord a bit - everything at the lowest possible level, of course, so we minimalize side effects
ActiveRecord::ConnectionAdapters::Column.class_eval do
  def date?
    klass == Date
  end

  def time?
    klass == Time
  end
end

ActiveRecord::Base.class_eval do
  def write_attribute_with_localization(attr_name, original_value)
    new_value = original_value
    if column = column_for_attribute(attr_name.to_s)
      if column.date?
        new_value = Date.parse_localized(original_value) rescue original_value
      elsif column.time?
        new_value = Time.parse_localized(original_value) rescue original_value
      end
    end
    write_attribute_without_localization(attr_name, new_value)
  end
  alias_method_chain :write_attribute, :localization

  # ugh
  def self.define_write_method_for_time_zone_conversion(attr_name)
    method_body = <<-EOV
      def #{attr_name}=(time)
        unless time.acts_like?(:time)
          time = time.is_a?(String) ? (I18n.delocalization_enabled? ? Time.zone.parse_localized(time) : Time.zone.parse(time)) : time.to_time rescue time
        end
        time = time.in_time_zone rescue nil if time
        write_attribute(:#{attr_name}, time)
      end
    EOV
    evaluate_attribute_method attr_name, method_body, "#{attr_name}="
  end

  def convert_number_column_value_with_localization(value)
    value = convert_number_column_value_without_localization(value)
    value = Numeric.parse_localized(value) if I18n.delocalization_enabled?
    value
  end
  alias_method_chain :convert_number_column_value, :localization

  def field_changed?(attr, old, value)
    if column = column_for_attribute(attr)
      if column.number? && column.null && (old.nil? || old == 0) && value.blank?
        # For nullable numeric columns, NULL gets stored in database for blank (i.e. '') values.
        # Hence we don't record it as a change if the value changes from nil to ''.
        # If an old value of 0 is set to '' we want this to get changed to nil as otherwise it'll
        # be typecast back to 0 (''.to_i => 0)
        value = nil
      elsif column.number?
        value = column.type_cast(convert_number_column_value_with_localization(value))
      else
        value = column.type_cast(value)
      end
    end

    old != value
  end
end
