# delocalize

[![Build Status](https://secure.travis-ci.org/clemens/delocalize.png)](http://travis-ci.org/clemens/delocalize)

delocalize provides localized date/time and number parsing functionality for Rails.

## Demo Application

Find a demo application [here](https://github.com/clemens/delocalize_demo).

## Compability

This gem requires the following versions:

* Ruby >= 1.9.2
* Rails >= 3.0 (Rails 2 and probably even Rails 1 *should* work but aren't officially supported)

Check [the Travis configuration](https://github.com/clemens/delocalize/blob/1-0-beta/.travis.yml) in order to see which configurations we are testing.

## Installation

You can use delocalize as a gem. Using delocalize as a Rails plugin has been discontinued and is no supported. If you want/need to use delocalize as a plugin (I really don't see a reason why you'd want to), consider using the `0-2-stable` branch.

### Rails 3

To use delocalize, put the following gem requirement in your `Gemfile`:

```ruby
gem "delocalize"
```

### Rails 2

Note: Official support for Rails 2 has been discontinued. However, due to the way this gem has been rewritten for its 1.0.0 release, it *should* work with Rails 2 just fine. If you run into any problems, consider filing an issue.

To use delocalize, put the following gem requirement in your `environment.rb`:

```ruby
config.gem "delocalize", :source => 'http://gemcutter.org'
```

In Rails 2.3, alternatively, you can use it with Bundler. See http://gembundler.com/rails23.html for instructions.

## What does it do? And how do I use it?

Delocalize, just as the name suggest, does pretty much the opposite of localize.

In the grey past, if you want your users to be able to input localized data, such as dates and numbers, you had to manually override attribute accessors:

```ruby
def price=(price)
  write_attribute(:price, price.gsub(',', '.'))
end
```

You also had to take care of proper formatting in forms on the frontend so people would see localized values in their forms.

Delocalize does most of this under the covers. All you need is a simple setup in your controllers and your regular translation data (as YAML or Ruby file) where you need Rails' standard translations.

### Controller setup

The approach used in delocalize is based on Rails' own `strong_parameters`. In fact, if you are on Rails 3 with the `strong_parameters` gem installed or Rails 4 (which includes it by default), delocalize is mixed straight into the provided `ActionController::Parameters` class. Otherwise it uses its own similar class (`Delocalize::Parameters`).

You can then use delocalize as you would use strong_parameters:

``` ruby
class ProductsController < ApplicationController
  def create
    Product.create(product_params)
  end

private

  def product_params
    delocalize_config = { :released_on => :date, :available_until => :time, :price => :number }
    # with strong_parameters
    params.require(:product).permit(*delocalize_config.keys).delocalize(delocalize_config)
    # without strong_parameters
    params.delocalize(:product => delocalize_config)[:product]
    # or
    params[:product].delocalize(delocalize_config)
  end

end
```

If you want to delocalize only certain parameters, configure those parameters and leave the others out – they will be kept as they are.

### Views

Delocalize doesn't automatically localize your data again (yet). There are various reasons for that but the main reasons are:

- It's hard to do this properly with some amount of flexibility for you as the user of the gem without crazy hacks of Rails internals (a problem that delocalize previously suffered from).
- Personally I feel that presentation logic (including forms) should be split out into separate objects (presenters, decorators, form objects and the like).

I might change my mind but as it stands but for the time being the gist is: Wherever you want to see localized values, you have to localize them yourself.

Examples:

``` ruby
text_field :product, :released_on, :value => product.released_on ? l(product.released_on) : nil
text_field_tag 'product[price]', number_with_precision(product.price, :precision => 2)
```

You can of course use something like the [Draper gem](https://github.com/drapergem/draper) or the great [Reform gem](https://github.com/apotonick/reform) to wrap your actual object and override the relevant accessors.

Check out how this can be done in the [demo app](https://github.com/clemens/delocalize_demo).

### Locale setup

In addition to your controller setup, you also need to configure your locale file(s). If you intend to use delocalize, you probably have a working locale file anyways. In this case, you only need to add two extra keys: `date.input.formats` and `time.input.formats`.

Assuming you want to use all of delocalize's parsers (date, time, number), the required keys are:
* number.format.delimiter
* number.format.separator
* date.input.formats
* time.input.formats
* date.formats.SOME_FORMAT for all formats specified in date.input.formats
* time.formats.SOME_FORMAT for all formats specified in time.input.formats

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

**Be careful with formats containing only numbers: It's very hard to produce reliable matches if you provide multiple strictly numeric formats!**

### Contributors and Copyright

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

Copyright (c) 2009-2015 Clemens Kofler <clemens@railway.at>
<http://www.railway.at/>
Released under the MIT license
