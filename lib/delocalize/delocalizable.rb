require 'active_support/concern'

module Delocalize
  module Delocalizable
    extend ActiveSupport::Concern

    included do
      class_attribute :delocalizable_fields
    end

    module ClassMethods
      def delocalize(*fields)
        self.delocalizable_fields ||= []
        self.delocalizable_fields += fields.map(&:to_sym)
        self.delocalizable_fields.uniq!
      end

      def delocalizes?(field)
        delocalizable_fields.include?(field.to_sym)
      end
    end
  end
end
