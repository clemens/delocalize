$: << 'lib'

require 'active_support/all'
require 'i18n'

require 'timecop'

begin
  require 'minitest/autorun'
rescue LoadError
  # not to worry, we're probably on Ruby 1.8
end
