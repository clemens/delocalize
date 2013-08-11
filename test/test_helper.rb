# encoding: utf-8

require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

require 'rails/all'

require 'test/unit'
require 'minitest/spec'
require 'mocha/setup'

require 'delocalize/rails_ext/action_view'
require 'delocalize/rails_ext/active_record'

de = {
  :date => {
    :input => {
      :formats => [:long, :short, :default]
    },
    :formats => {
      :default => "%d.%m.%Y",
      :short => "%e. %b",
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

I18n.locale = :de

class NonArProduct
  attr_accessor :name, :price, :times_sold,
    :cant_think_of_a_sensible_time_field,
    :released_on, :published_at
end

class Product < ActiveRecord::Base
end

class ProductWithValidation < Product
  validates_numericality_of :price
  validates_presence_of :price
end

class ProductWithBusinessValidation < Product
  validate do |record|
    if record.price > 10
      record.errors.add(:price, :invalid)
    end
  end
end

config = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
ActiveRecord::Base.establish_connection(config['test'])

ActiveRecord::Base.connection.create_table :products do |t|
  t.string :name
  t.date :released_on
  t.datetime :published_at
  t.time :cant_think_of_a_sensible_time_field
  t.decimal :price
  t.float :weight
  t.integer :times_sold
  t.decimal :some_value_with_default, :default => 0, :precision => 20, :scale => 2
end
