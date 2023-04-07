# frozen_string_literal: true

require "helper"

class TestProperties < Case
  class Property < DiscriminableModel
    enum type: { value: 0, single_option: 1, multi_option: 2, range: 3 }
    discriminable_attribute :type, value: "Value", single_option: "Option", multi_option: "Option",
                                   range: "Range"
  end

  class Value < Property; end
  class Option < Property; end
  class Range < Property; end

  def setup
    ActiveRecord::Schema.define do
      create_table :properties do |t|
        t.integer :type, limit: 1, default: 0
      end
    end
  end

  def test_sti_name_default
    assert_equal Value.sti_name, :value
    assert_equal Option.sti_name, :single_option
    assert_equal Range.sti_name, :range
  end

  def test_creation
    assert_predicate Value.create, :value?
    assert_predicate Option.create, :single_option?
    assert_predicate Range.create, :range?
  end

  def test_building
    assert_instance_of Value, Property.value.build
    assert_instance_of Option, Property.multi_option.build
    assert_instance_of Range, Property.range.build
  end

  def test_becomes
    value = Value.create
    range = value.becomes!(Range)
    range.save
    assert_instance_of TestProperties::Range, range
    assert_instance_of TestProperties::Range, range.reload
  end
end
