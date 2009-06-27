module I18n
  mattr_accessor :enable_delocalization
  I18n.enable_delocalization = true

  class << self
    def delocalization_enabled?
      !!I18n.enable_delocalization
    end

    def delocalization_disabled?
      !delocalization_enabled?
    end

    def with_delocalization_disabled(&block)
      old_value = I18n.enable_delocalization
      I18n.enable_delocalization = false
      yield
      I18n.enable_delocalization = old_value
    end

    def with_delocalization_enabled(&block)
      old_value = I18n.enable_delocalization
      I18n.enable_delocalization = true
      yield
      I18n.enable_delocalization = old_value
    end
  end
end