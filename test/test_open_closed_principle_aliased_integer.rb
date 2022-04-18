# frozen_string_literal: true

require "helper"

class TestOpenClosedPrincipleAliasedInteger < Case
  class Property < ActiveRecord::Base
    include Discriminable

    alias_attribute :kind, :kind_with_some_postfix

    # No enum this time
    discriminable_by :kind
  end

  class NumberProperty < Property
    discriminable_as 1
  end

  class OptionProperty < Property
    discriminable_as 2, 3
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :properties do |t|
        t.integer :kind_with_some_postfix, limit: 1, null: true
      end
    end
  end

  def test_sti_name_default
    assert_equal 1, NumberProperty.sti_name
    assert_equal 2, OptionProperty.sti_name
  end

  def test_creation_and_loading
    assert_equal 1, NumberProperty.create.kind
    assert_equal 2, OptionProperty.create.kind
    assert_instance_of NumberProperty, Property.first
    assert_instance_of OptionProperty, Property.last
  end

  def test_creation_using_parent
    assert_instance_of NumberProperty, Property.create(kind: 1)
    assert_instance_of OptionProperty, Property.create(kind: 3)
  end

  def test_building
    assert_instance_of NumberProperty, Property.new(kind: 1)
    assert_instance_of OptionProperty, Property.new(kind: 2)
    assert_instance_of OptionProperty, Property.new(kind: 3)
  end
end
