# let's hack into ActiveRecord a bit - everything at the lowest possible level, of course, so we minimalize side effects
ActiveRecord::ConnectionAdapters::Column.class_eval do
  def date?
    klass == Date
  end

  def time?
    klass == Time
  end

  def decimal?
    klass == BigDecimal
  end
end

ActiveRecord::Base.class_eval do
  def write_attribute_with_localization(attr_name, value)
    if column = column_for_attribute(attr_name.to_s)
      if column.date?
        value = Date.parse_localized(value)
      elsif column.time?
        value = Time.parse_localized(value)
      elsif column.decimal?
        value = convert_number_column_value_with_localization(value)
        value = BigDecimal(value) if value.is_a?(String)
      end
    end
    write_attribute_without_localization(attr_name, value)
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
    if I18n.delocalization_enabled? && value.is_a?(String)
      value = value.gsub(/[^0-9\-#{I18n.t(:'number.format.separator')}]/, '').gsub(I18n.t(:'number.format.separator'), '.')
    end
    value
  end
  alias_method_chain :convert_number_column_value, :localization
end
