if Gem::Version.new(ActionPack::VERSION::STRING) >= Gem::Version.new('4.0.0.beta')
  require 'delocalize/rails_ext/action_view_rails4'
else
  require 'delocalize/rails_ext/action_view_rails3'
end
