module Delocalize
  class Railtie < Rails::Railtie
    initializer "delocalize" do |app|
      ActiveSupport.on_load :action_controller do
        # By default, we use ActionController::Parameters provided by strong_parameters. If it's
        # not there, we fall back to our own replacement (Delocalize::Parameters).
        if defined?(ActionController::Parameters)
          ActionController::Parameters.send(:include, Delocalize::ParameterDelocalizing)
        else
          ActionController::Base.send(:include, Delocalize::DelocalizableParameters)
        end
      end
    end
  end
end
