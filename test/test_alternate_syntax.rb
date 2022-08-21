# frozen_string_literal: true

require "helper"

class TestAlternateSyntax < Case
  class Property < ActiveRecord::Base
    include Discriminable

    enum type: { value: 0, single_option: 1, multi_option: 2, range: 3 }
    discriminable_attribute :type
  end

  class ValueProperty < Property
    discriminable_value :value
  end

  class OptionProperty < Property
    discriminable_values :single_option, :multi_option
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :properties do |t|
        t.integer :type, limit: 1, default: 0
      end
    end
  end

  def test_sti_name_default
    assert_equal ValueProperty.sti_name, "value"
    assert_equal OptionProperty.sti_name, "single_option"
  end

  def test_creation
    assert_predicate ValueProperty.create, :value?
    assert_predicate OptionProperty.create, :single_option?
  end

  def test_building
    assert_instance_of ValueProperty, Property.value.build
    assert_instance_of OptionProperty, Property.multi_option.build
  end
end
