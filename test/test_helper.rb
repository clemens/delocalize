# encoding: utf-8

require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'

require 'rails'
# We need to explicitly load ActiveSupport's version of Hash#slice since Rails 3.2 somehow loads
# i18n's version first which is different from Rails' (see https://github.com/svenfuchs/i18n/commit/24e71a9a4901ed18c9cab5c53109fd9bf2416bcb).
require 'active_support/core_ext/hash/slice'

de = {
  :date => {
    :input => {
      :formats => [:long, :short, :short_with_name, :default]
    },
    :formats => {
      :default => "%d.%m.%Y",
      :short => "%e.%m.",
      :short_with_name => "%e. %b.",
      :long => "%e. %B %Y",
      :only_day => "%e"
    },
    :day_names => %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag),
    :abbr_day_names => %w(So Mo Di Mi Do Fr Sa),
    :month_names => [nil] + %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember),
    :abbr_month_names => [nil] + %w(Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez)
  },
  :time => {
    :input => {
      :formats => [:long, :medium, :short, :default, :time]
    },
    :formats => {
      :default => "%A, %e. %B %Y, %H:%M Uhr",
      :short => "%e. %B, %H:%M Uhr",
      :medium => "%e. %B %Y, %H:%M Uhr",
      :long => "%A, %e. %B %Y, %H:%M Uhr",
      :time => "%H:%M Uhr"
    },
    :am => 'vormittags',
    :pm => 'nachmittags'
  },
  :number => {
    :format => {
      :precision => 2,
      :separator => ',',
      :delimiter => '.'
    }
  },
  :activerecord => {
    :errors => {
      :messages => {
        :not_a_number => 'is not a number'
      }
    }
  }
}

# deeply clone the hash for a fantasy language called tt
tt = Marshal.load(Marshal.dump(de))
tt[:date][:formats][:default] = '%d|%m|%Y'

I18n.backend.store_translations :de, de
I18n.backend.store_translations :tt, tt

I18n.default_locale = :de
I18n.locale = :de
