delocalize
==========

delocalize provides localized date/time and number parsing functionality for Rails.

Installation
------------

You can use delocalize either as a gem (preferred) or as a Rails plugin.

### Rails 3

To use the gem version, put the following gem requirement in your `Gemfile`:

    gem "delocalize"

To install it as a plugin, fire up your terminal, go to your Rails app and type:

    $ ruby rails plugin install git://github.com/clemens/delocalize.git

### Rails 2

To use the gem version, put the following gem requirement in your `environment.rb`:

    config.gem "delocalize", :source => 'http://gemcutter.org'

To install it as a plugin, fire up your terminal, go to your Rails app and type:

    $ ruby script/plugin install git://github.com/clemens/delocalize.git


What does it do? And how do I use it?
--------------------------------------

Delocalize, just as the name suggest, does pretty much the opposite of localize.

In the grey past, if you want your users to be able to input localized data, such as dates and numbers, you had to manually override attribute accessors:

    def price=(price)
      write_attribute(:price, price.gsub(',', '.'))
    end

delocalize does this under the covers -- all you need is your regular translation data (as YAML or Ruby file) where you need Rails' standard translations:

    de:
      number:
        format:
          separator: ','
          delimiter: '.'
      date:
        input:
          formats: [:default, :long, :short] # <- this and ...

        formats:
          default: "%d.%m.%Y"
          short: "%e. %b"
          long: "%e. %B %Y"
          only_day: "%e"

        day_names: [Sonntag, Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag]
        abbr_day_names: [So, Mo, Di, Mi, Do, Fr, Sa]
        month_names: [~, Januar, Februar, März, April, Mai, Juni, Juli, August, September, Oktober, November, Dezember]
        abbr_month_names: [~, Jan, Feb, Mär, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez]
        order: [ :day, :month, :year ]

      time:
        input:
          formats: [:long, :medium, :short, :default, :time] # <- ... this are the only non-standard keys
        formats:
          default: "%A, %e. %B %Y, %H:%M Uhr"
          short: "%e. %B, %H:%M Uhr"
          long: "%A, %e. %B %Y, %H:%M Uhr"
          time: "%H:%M"

        am: "vormittags"
        pm: "nachmittags"

For dates and times, you have to define input formats which are taken from the actual formats. The important thing here is to define input formats sorted by descending complexity; in other words: the format which contains the most (preferably non-numeric) information should be first in the list because it can produce the most reliable match. Exception: If you think there most complex format is not the one that most users will input, you can put the most-used in front so you save unnecessary iterations.

Careful with formats containing only numbers: It's very hard to produce reliable matches if you provide multiple strictly numeric formats!

delocalize then overrides `to_input_field_tag` in ActionView's `InstanceTag` so you can use localized text fields:

    <% form_for @product do |f| %>
      <%= f.text_field :name %>
      <%= f.text_field :released_on %>
      <%= f.text_field :price %>
    <% end %>
  
In this example, a user can enter the release date and the price just like he's used to in his language, for example:

>  Name: "Couch"  
>  Released on: "12. Oktober 2009"  
>  Price: "2.999,90"

When saved, ActiveRecord automatically converts these to a regular Ruby date and number.

Edit forms then also show localized dates/numbers. By default, dates and times are localized using the format named :default in your locale file. So with the above locale file, dates would use `%d.%m.%Y` and times would use `%A, %e. %B %Y, %H:%M Uhr`. Numbers are also formatted using your locale's thousands delimiter and decimal separator.

You can also customize the output using some options:

  The price should always show two decimal digits and we don't need the delimiter:
      <%= f.text_field :price, :precision => 2, :delimiter => '' %>
  
  The `released_on` date should be shown in the `:full` format:
      <%= f.text_field :released_on, :format => :full %>
  
  Since `I18n.localize` supports localizing `strftime` strings, we can also do this:
      <%= f.text_field :released_on, :format => "%B %Y" %>

### Compatibility

* Tested with Rails 2.3.5 in Ruby 1.8.7, Ruby 1.9.1 and Ruby 1.9.2 (head)
* Tested with Rails 3 Beta 3 in Ruby 1.9.2 (head)

### Contributors

People who have contributed to delocalize (in no particular order):

* [Fernando Luizao](http://github.com/fernandoluizao)
* [Stephan](http://github.com/stepahn)
* [Lailson Bandeira](http://github.com/lailsonbm)
* [Carlos Antonio da Silva](http://github.com/carlosantoniodasilva)
* [Michele Franzin](http://github.com/michelefranzin)

### TODO

* Improve test coverage
* Separate Ruby/Rails stuff to make it usable outside Rails
* Decide on other ActionView hacks (e.g. `text_field_tag`)
* Implement AM/PM support
* Cleanup, cleanup, cleanup ...

Copyright (c) 2009-2011 Clemens Kofler <clemens@railway.at>
<http://www.railway.at/>
Released under the MIT license
