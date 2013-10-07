ActiveRecord::ConnectionAdapters::Column.class_eval do
  def type_cast_with_localization(value)
    new_value = value
    if date?
      new_value = Date.parse_localized(value) rescue value
    elsif time?
      new_value = Time.parse_localized(value) rescue value
    elsif number?
      new_value = Numeric.parse_localized(value) rescue value
    end
    type_cast_without_localization(new_value)
  end

  alias_method_chain :type_cast, :localization

  def type_cast_for_write_with_localization(value)
    if number? && I18n.delocalization_enabled?
      value = Numeric.parse_localized(value)
      if type == :integer
        value = value.to_i
      else
        value = value.to_f
      end
    end
    type_cast_for_write_without_localization(value)
  end

  alias_method_chain :type_cast_for_write, :localization
end
