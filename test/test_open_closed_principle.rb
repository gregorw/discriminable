# frozen_string_literal: true

require "helper"

class TestOpenClosedPrinciple < Case
  class Property < ActiveRecord::Base
    include Discriminable

    enum kind: { number: 0, single_option: 1, multi_option: 2, range: 3 }
    discriminable_by :kind
  end

  class NumberProperty < Property
    discriminable_as :number
  end

  class OptionProperty < Property
    discriminable_as :single_option, :multi_option
  end

  class RangeProperty < Property
    discriminable_as :range
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :properties do |t|
        t.integer :kind, limit: 1, default: 0
      end
    end
  end

  def test_sti_name_default
    assert_equal NumberProperty.sti_name, "number"
    assert_equal OptionProperty.sti_name, "single_option"
    assert_equal RangeProperty.sti_name, "range"
  end

  def test_creation
    assert_predicate NumberProperty.create, :number?
    assert_predicate OptionProperty.create, :single_option?
    assert_predicate RangeProperty.create, :range?
  end

  def test_building
    assert_instance_of NumberProperty, Property.number.build
    assert_instance_of OptionProperty, Property.multi_option.build
    assert_instance_of RangeProperty, Property.range.build
  end
end
