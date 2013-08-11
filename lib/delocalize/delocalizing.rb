# FIXME I don't like that I add a dozen methods to each controller. Maybe extract an object?
module Delocalize
  module Delocalizing
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :delocalize_params

      def delocalize(options = {})
        filter_options = options.slice(:only, :except)
        self.delocalize_params = options.except(:only, :except)

        before_filter(:perform_delocalization, filter_options)

        true
      end
    end

    def perform_delocalization
      delocalize_hash(params)
    end

  private

    def delocalize_hash(hash, key_stack = [])
      hash.each do |key, value|
        hash[key] = value.is_a?(Hash) ? delocalize_hash(hash[key], key_stack + [key]) : delocalize_parser_for(key_stack + [key]).parse(value)
      end
    end

    def delocalize_parser_for(key_stack)
      parser_type = key_stack.reduce(self.class.delocalize_params) { |h, key| h[key] }
      send("delocalize_#{parser_type}_parser")
    end

    def delocalize_number_parser
      @delocalize_number_parser ||= Delocalize::LocalizedNumericParser.new
    end

    def delocalize_time_parser
      @delocalize_time_parser ||= Delocalize::LocalizedDateTimeParser.new(Time)
    end

    def delocalize_date_parser
      @delocalize_date_parser ||= Delocalize::LocalizedDateTimeParser.new(Date)
    end

  end
end
