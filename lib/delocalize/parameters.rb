# blatantly copied from strong_parameters's ActionController::Parameters :)

require 'active_support/core_ext/hash/indifferent_access'

module Delocalize
  class Parameters < ActiveSupport::HashWithIndifferentAccess
    include ParameterDelocalizing

    def [](key)
      convert_hashes_to_parameters(key, super)
    end

  private

    def convert_hashes_to_parameters(key, value)
      if value.is_a?(self.class) || !value.is_a?(Hash)
        value
      else
        # convert on first access
        self[key] = self.class.new(value)
      end
    end

  end
end
