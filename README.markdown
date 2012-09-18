delocalize
==========

[![Build Status](https://secure.travis-ci.org/clemens/delocalize.png)](http://travis-ci.org/clemens/delocalize)

delocalize provides localized date/time and number parsing functionality for Rails.

Installation
------------

You can use delocalize as a gem (preferred). Using delocalize as a Rails plugin has been discontinued and is no supported. If you want/need to use delocalize as a gem (I really don't see a reason why you'd want to), consider using the `0-2-stable` branch.

### Rails 3

To use delocalize, put the following gem requirement in your `Gemfile`:

```ruby
gem "delocalize"
```

### Rails 2

Note: Support for Rails 2 has been discontinued. This version is only considered stable for Rails 3. If you need Rails 2 support, please use the `0.2.x` versions or the `0-2-stable` branch respectively.

To use delocalize, put the following gem requirement in your `environment.rb`:

```ruby
config.gem "delocalize", :source => 'http://gemcutter.org'
```

In Rails 2.3, alternatively, you can use it with Bundler. See http://gembundler.com/rails23.html for instructions.

What does it do? And how do I use it?
--------------------------------------

Delocalize, just as the name suggest, does pretty much the opposite of localize.

In the grey past, if you want your users to be able to input localized data, such as dates and numbers, you had to manually override attribute accessors:

```ruby
def price=(price)
  write_attribute(:price, price.gsub(',', '.'))
end
```

delocalize does this under the covers -- all you need is your regular translation data (as YAML or Ruby file) where you need Rails' standard translations:

```yml
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
```

For dates and times, you have to define input formats which are taken from the actual formats. The important thing here is to define input formats sorted by descending complexity; in other words: the format which contains the most (preferably non-numeric) information should be first in the list because it can produce the most reliable match. Exception: If you think there most complex format is not the one that most users will input, you can put the most-used in front so you save unnecessary iterations.

Careful with formats containing only numbers: It's very hard to produce reliable matches if you provide multiple strictly numeric formats!

delocalize then overrides `to_input_field_tag` in ActionView's `InstanceTag` so you can use localized text fields:

```erb
<% form_for @product do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :released_on %>
  <%= f.text_field :price %>
<% end %>
```

In this example, a user can enter the release date and the price just like he's used to in his language, for example:

>  Name: "Couch"  
>  Released on: "12. Oktober 2009"  
>  Price: "2.999,90"

When saved, ActiveRecord automatically converts these to a regular Ruby date and number.

Edit forms then also show localized dates/numbers. By default, dates and times are localized using the format named :default in your locale file. So with the above locale file, dates would use `%d.%m.%Y` and times would use `%A, %e. %B %Y, %H:%M Uhr`. Numbers are also formatted using your locale's thousands delimiter and decimal separator.

You can also customize the output using some options:

  The price should always show two decimal digits and we don't need the delimiter:
  
```erb
<%= f.text_field :price, :precision => 2, :delimiter => '' %>
```
  
  The `released_on` date should be shown in the `:full` format:

```erb
<%= f.text_field :released_on, :format => :full %>
```

  Since `I18n.localize` supports localizing `strftime` strings, we can also do this:

```erb
<%= f.text_field :released_on, :format => "%B %Y" %>
```

### Ruby 1.9 + Psych YAML Parser

You will need to adjust the localization formatting when using the new YAML parser Psych.  Below is an example error message you may receive in your logs as well as an example of acceptable formatting and helpful links for reference:

__Error message from logs:__

    Psych::SyntaxError (couldn't parse YAML at line x column y):

__References:__

The solution can be found here: http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml#answer-5323060

http://pivotallabs.com/users/mkocher/blog/articles/1692-yaml-psych-and-ruby-1-9-2-p180-here-there-be-dragons

__Psych Preferred Formatting:__

```yml
en:
  number:
    format:
      separator: '.'
      delimiter: ','
      precision: 2
  date:
    input:
      formats:
        - :default
        - :long
        - :short
    formats:
      default: "%m/%d/%Y"
      short: "%b %e"
      long: "%B %e, %Y"
      only_day: "%e"
    day_names:
      - Sunday
      - Monday
      - Tuesday
      - Wednesday
      - Thursday
      - Friday
      - Saturday
    abbr_day_names:
      - Sun
      - Mon
      - Tue
      - Wed
      - Thur
      - Fri
      - Sat
    month_names:
      - ~
      - January
      - February
      - March
      - April
      - May
      - June
      - July
      - August
      - September
      - October
      - November
      - December
    abbr_month_names:
      - ~
      - Jan
      - Feb
      - Mar
      - Apr
      - May
      - Jun
      - Jul
      - Aug
      - Sep
      - Oct
      - Nov
      - Dec
    order:
      - :month
      - :day
      - :year
  time:
    input:
      formats: 
        - :default
        - :long
        - :short
        - :time
    formats:
      default: "%m/%d/%Y %I:%M%p"
      short: "%B %e %I:%M %p"
      long: "%A, %B %e, %Y %I:%M%p"
      time: "%l:%M%p"
    am: "am"
    pm: "pm"
```

### Compatibility

* Tested with Rails 2.3.5 in Ruby 1.8.7, Ruby 1.9.1 and Ruby 1.9.2 (head)
* Tested with Rails 3 Beta 3 in Ruby 1.9.2 (head)

### Contributors

People who have contributed to delocalize (in no particular order):

* [Fernando Luizao](http://github.com/fernandoluizao)
* [Stephan Zalewski](http://github.com/stepahn)
* [Lailson Bandeira](http://github.com/lailsonbm)
* [Carlos Antonio da Silva](http://github.com/carlosantoniodasilva)
* [Michele Franzin](http://github.com/michelefranzin)
* [Raphaela Wrede](https://github.com/rwrede)
* [Jan De Poorter](https://github.com/DefV)
* [Blake Lucchesi](https://github.com/BlakeLucchesi)
* [Ralph von der Heyden](https://github.com/ralph)

### TODO

* Improve test coverage
* Separate Ruby/Rails stuff to make it usable outside Rails
* Decide on other ActionView hacks (e.g. `text_field_tag`)
* Implement AM/PM support
* Cleanup, cleanup, cleanup ...

Copyright (c) 2009-2011 Clemens Kofler <clemens@railway.at>
<http://www.railway.at/>
Released under the MIT license
