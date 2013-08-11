module Delocalize
  class Railtie < Rails::Railtie
    initializer "delocalize" do |app|
      ActiveSupport.on_load :action_controller do
        if defined?(ActionController::Parameters)
          ActionController::Parameters.send(:include, Delocalize::ParameterDelocalizing)
        end
      end
    end
  end
end
