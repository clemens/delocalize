require 'test_helper'
require 'action_controller'

parameters_classes = [Delocalize::Parameters]

if defined?(ActionController::Parameters)
  # FIXME Can this happen automatically, e.g. by loading the Railtie?
  ActionController::Parameters.send(:include, Delocalize::ParameterDelocalizing)
  parameters_classes << ActionController::Parameters
end

puts "Testing parameter classes: #{parameters_classes.inspect}"

parameters_classes.each do |parameters_class|
  describe parameters_class do
    before do
      Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
    end

    it "delocalizes top level params based on the given options" do
      params = parameters_class.new(:released_on => '21. Mai 1986', :available_until => '25. Dezember 2013, 23:59 Uhr', :price => '1.299,99')

      delocalized_params = params.delocalize(:released_on => :date, :available_until => :time, :price => :number)

      delocalized_params[:released_on].must_equal Date.civil(1986, 5, 21)
      delocalized_params[:available_until].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      delocalized_params[:price].must_equal '1299.99'
    end

    it "delocalizes nested params based on the given options" do
      params = parameters_class.new(:product => { :released_on => '21. Mai 1986', :available_until => '25. Dezember 2013, 23:59 Uhr', :price => '1.299,99' })

      delocalized_params = params.delocalize(:product => { :released_on => :date, :available_until => :time, :price => :number })

      delocalized_params[:product][:released_on].must_equal Date.civil(1986, 5, 21)
      delocalized_params[:product][:available_until].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      delocalized_params[:product][:price].must_equal '1299.99'
    end

    it "delocalizes field-for type params based on the given options" do
      params = parameters_class.new(
          :product => {
              variant_attributes: {
                  "0" => { :released_on => '21. Mai 1986', :available_until => '25. Dezember 2013, 23:59 Uhr', :price => '1.299,99' },
                  "1" => { :released_on => '1. Juni 2001', :available_until => '12. November 2014, 00:00 Uhr', :price => '1.099,01' },
              }
          }
      )

      delocalized_params = params.delocalize(:product => { :variant_attributes => { :released_on => :date, :available_until => :time, :price => :number } })

      delocalized_params[:product][:variant_attributes]['0'][:released_on].must_equal Date.civil(1986, 5, 21)
      delocalized_params[:product][:variant_attributes]['0'][:available_until].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      delocalized_params[:product][:variant_attributes]['0'][:price].must_equal '1299.99'

      delocalized_params[:product][:variant_attributes]['1'][:released_on].must_equal Date.civil(2001, 6, 1)
      delocalized_params[:product][:variant_attributes]['1'][:available_until].must_equal Time.zone.local(2014, 11, 12, 00, 00)
      delocalized_params[:product][:variant_attributes]['1'][:price].must_equal '1099.01'
    end

    it "delocalizes nested params on the key itself based on the given options" do
      params = parameters_class.new(:product => { :released_on => '21. Mai 1986', :available_until => '25. Dezember 2013, 23:59 Uhr', :price => '1.299,99' })

      product_params = params[:product].delocalize(:released_on => :date, :available_until => :time, :price => :number)

      product_params[:released_on].must_equal Date.civil(1986, 5, 21)
      product_params[:available_until].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      product_params[:price].must_equal '1299.99'
    end

    it "delocalizes deeply nested params for one-to-one based on the given  options" do
      params = parameters_class.new(:parent => { :child => { :child_date => '21. Mai 1986', :child_time => '25. Dezember 2013, 23:59 Uhr', :child_number => '1.299,99' } })

      delocalized_params = params.delocalize(:parent => { :child => { :child_date => :date, :child_time => :time, :child_number => :number } })

      delocalized_params[:parent][:child][:child_date].must_equal Date.civil(1986, 5, 21)
      delocalized_params[:parent][:child][:child_time].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      delocalized_params[:parent][:child][:child_number].must_equal '1299.99'
    end

    it "delocalizes deeply nested params for one-to-one on the key itself based on the given  options" do
      params = parameters_class.new(:parent => { :child => { :child_date => '21. Mai 1986', :child_time => '25. Dezember 2013, 23:59 Uhr', :child_number => '1.299,99' } })

      parent_params = params[:parent].delocalize(:child => { :child_date => :date, :child_time => :time, :child_number => :number })

      parent_params[:child][:child_date].must_equal Date.civil(1986, 5, 21)
      parent_params[:child][:child_time].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      parent_params[:child][:child_number].must_equal '1299.99'
    end

    it "delocalizes all the things at all the levels of all the types" do
      delocalize_options = {
        :top_level_date => :date,
        :top_level_time => :time,
        :top_level_number => :number,
        :parent => {
          :parent_date => :date,
          :parent_time => :time,
          :parent_number => :number,
          :child => {
            :child_date => :date,
            :child_time => :time,
            :child_number => :number
          }
        }
      }

      params = parameters_class.new(
        :top_level_date => '21. Mai 1986',
        :top_level_time => '25. Dezember 2013, 23:59 Uhr',
        :top_level_number => '1.299,99',
        :parent => {
          :parent_date => '21. Mai 2004',
          :parent_time => '24. Dezember 2013, 23:59 Uhr',
          :parent_number => '999,99',
          :child => {
            :child_date => '21. Mai 2011',
            :child_time => '31. Dezember 2013, 23:59 Uhr',
            :child_number => '9.999'
          }
        }
      )

      delocalized_params = params.delocalize(delocalize_options)

      delocalized_params[:top_level_date].must_equal Date.civil(1986, 5, 21)
      delocalized_params[:top_level_time].must_equal Time.zone.local(2013, 12, 25, 23, 59)
      delocalized_params[:top_level_number].must_equal '1299.99'

      delocalized_params[:parent][:parent_date].must_equal Date.civil(2004, 5, 21)
      delocalized_params[:parent][:parent_time].must_equal Time.zone.local(2013, 12, 24, 23, 59)
      delocalized_params[:parent][:parent_number].must_equal '999.99'

      delocalized_params[:parent][:child][:child_date].must_equal Date.civil(2011, 5, 21)
      delocalized_params[:parent][:child][:child_time].must_equal Time.zone.local(2013, 12, 31, 23, 59)
      delocalized_params[:parent][:child][:child_number].must_equal '9999'
    end

    # TODO Figure out deeply nested params for one-to-many relations.
    # The problem is that one-to-many relations may be given as a hash or an array. Delocalize should
    # be able both cases just fine.

    it "fails for a non-existent type" do
      params = parameters_class.new(:available_until => '25. Dezember 2013, 23:59 Uhr')

      ->{ params.delocalize(:available_until => :datetime) }.must_raise(Delocalize::ParserNotFound)
    end

    it "keeps unconfigured parameters as they are while still delocalizing others" do
      params = parameters_class.new(:released_on => '1986-05-21', :price => '1.299,99')

      delocalized_params = params.delocalize(:price => :number)

      delocalized_params[:released_on].must_equal '1986-05-21'
      delocalized_params[:price].must_equal '1299.99'
    end
    
    it "doesn't raise when nested params given and which aren't defined in options" do
      params = parameters_class.new(:parent => { :parent_date => '21. Mai 2004' })

      ## Should not throw an error:
      params.delocalize({})
    end

    it "delocalizes arrays" do
      params = parameters_class.new(:location => ['13,456', '51,234'], :interval => ['25. Dezember 2013', '31. Januar 2014'])

      delocalized_params = params.delocalize(:location => [:number], interval: [:date])

      delocalized_params[:location].must_equal ['13.456', '51.234']
      delocalized_params[:interval].must_equal [Date.civil(2013, 12, 25), Date.civil(2014, 1, 31)]
    end
  end
end
