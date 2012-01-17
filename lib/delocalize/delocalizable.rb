require 'active_support/concern'

module Delocalize
  module Delocalizable
    extend ActiveSupport::Concern

    included do
      class_attribute :delocalizable_fields
      class_attribute :delocalize_conversions
    end

    module ClassMethods
      def delocalize(conversions = {})
        self.delocalize_conversions ||= {}
        self.delocalizable_fields ||= []

        conversions.each do |field, type|
          delocalizable_fields << field.to_sym unless delocalizable_fields.include?(field.to_sym)
          delocalize_conversions[field.to_sym] = type.to_sym
        end
      end

      def delocalizing?
        delocalizable_fields.any?
      end

      def delocalizes?(field)
        delocalizing? && (delocalizable_fields || []).include?(field.to_sym)
      end

      def delocalizes_type_for(field)
        delocalize_conversions[field.to_sym]
      end
    end

    # The instance methods are just here for convenience. They all delegate to their class.
    module InstanceMethods
      def delocalizing?
        self.class.delocalizing?
      end

      def delocalizes?(field)
        self.class.delocalizes?(field)
      end

      def delocalizes_type_for(field)
        self.class.delocalizes_type_for(field)
      end
    end
  end
end
