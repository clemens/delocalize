# encoding: utf-8

ENV["RAILS_ENV"] = "test"
rails_version = ENV["RAILS_VERSION"] || 2

if rails_version.to_i == 2
  require File.expand_path(File.join(File.dirname(__FILE__), "rails2_app/config/environment"))
  require 'test_help'
else
  require File.expand_path(File.join(File.dirname(__FILE__), "rails#{rails_version}_app/config/environment"))
  require 'rails/test_help'
end

I18n.backend.store_translations :de, {
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
  }
}

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
