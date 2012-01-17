module Delocalize
  class Railtie < Rails::Railtie
    initializer "delocalize" do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:include, Delocalize::Delocalizable)
      end

      ActiveSupport.on_load :action_view do
        require 'delocalize/rails_ext/action_view'
      end

      require 'delocalize/rails_ext/time_zone'
    end
  end
end
