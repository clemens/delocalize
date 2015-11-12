# blatantly copied from strong_parameters's ActionController::Parameters :)

module Delocalize
  module DelocalizableParameters
    extend ActiveSupport::Concern

    def params
      @_params ||= Parameters.new(request.parameters)
    end

    def params=(val)
      @_params = val.is_a?(Hash) ? Parameters.new(val) : val
    end
  end
end
