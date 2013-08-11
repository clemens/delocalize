require 'test_helper'

class DelocalizingController
  include Delocalize::Delocalizing

  def self.before_filter(*); end
end

describe DelocalizingController do
  before do
    Time.zone = 'Berlin' # make sure everything works as expected with TimeWithZone
  end

  it "attaches a before_filter when calling delocalize" do
    DelocalizingController.expects(:before_filter).with(:perform_delocalization, {})
    DelocalizingController.delocalize.wont_be_nil
  end

  it "passes the :only option to the underlying filter when calling delocalize" do
    DelocalizingController.expects(:before_filter).with(:perform_delocalization, :only => [:create, :update])
    DelocalizingController.delocalize(:only => [:create, :update])
  end

  it "passes the :except option to the underlying filter when calling delocalize" do
    DelocalizingController.expects(:before_filter).with(:perform_delocalization, :except => [:create, :update])
    DelocalizingController.delocalize(:except => [:create, :update])
  end

  it "stores the parameters to be be delocalized" do
    params = { :product => { :released_on => :date, :available_until => :time, :price => :number } }
    DelocalizingController.delocalize(params)
    DelocalizingController.delocalize_params.must_equal params
  end

  # the filter itself
  it "delocalizes top level params based on the configured parameters" do
    DelocalizingController.delocalize_params = { :released_on => :date, :available_until => :time, :price => :number }
    controller = DelocalizingController.new
    controller.stubs(:params).returns(:released_on => '21. Mai 1986', :available_until => '25. Dezember 2013, 23:59 Uhr', :price => '1.299,99')

    controller.perform_delocalization
    controller.params.must_equal({ :released_on => Date.civil(1986, 5, 21), :available_until => Time.zone.local(2013, 12, 25, 23, 59), :price => '1299.99' })
  end

  it "delocalizes nested params based on the configured parameters" do
    DelocalizingController.delocalize_params = { :product => { :released_on => :date, :available_until => :time, :price => :number } }
    controller = DelocalizingController.new
    controller.stubs(:params).returns(:product => { :released_on => '21. Mai 1986', :available_until => '25. Dezember 2013, 23:59 Uhr', :price => '1.299,99' })

    controller.perform_delocalization
    controller.params.must_equal({ :product => { :released_on => Date.civil(1986, 5, 21), :available_until => Time.zone.local(2013, 12, 25, 23, 59), :price => '1299.99' } })
  end

  it "delocalizes deeply nested params for one-to-one based on the configured parameters" do
    DelocalizingController.delocalize_params = { :parent => { :child => { :some_date => :date, :some_time => :time, :some_number => :number } } }
    controller = DelocalizingController.new
    controller.stubs(:params).returns(:parent => { :child => { :some_date => '21. Mai 1986', :some_time => '25. Dezember 2013, 23:59 Uhr', :some_number => '1.299,99' } })

    controller.perform_delocalization
    controller.params.must_equal({ :parent => { :child => { :some_date => Date.civil(1986, 5, 21), :some_time => Time.zone.local(2013, 12, 25, 23, 59), :some_number => '1299.99' } } })
  end

  it "delocalizes all the things at all the levels of all the types" do
    DelocalizingController.delocalize_params = {
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
    controller = DelocalizingController.new
    controller.stubs(:params).returns(
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

    controller.perform_delocalization
    controller.params.must_equal({
      :top_level_date => Date.civil(1986, 5, 21),
      :top_level_time => Time.zone.local(2013, 12, 25, 23, 59),
      :top_level_number => '1299.99',
      :parent => {
        :parent_date => Date.civil(2004, 5, 21),
        :parent_time => Time.zone.local(2013, 12, 24, 23, 59),
        :parent_number => '999.99',
        :child => {
          :child_date => Date.civil(2011, 5, 21),
          :child_time => Time.zone.local(2013, 12, 31, 23, 59),
          :child_number => '9999'
        }
      }
    })
  end

  # TODO Figure out deeply nested params for one-to-many relations.
  # The problem is that one-to-many relations may be given as a hash or an array. Delocalize should
  # be able both cases just fine.
end
