# frozen_string_literal: true

require "helper"

class TestOn < Case
  class Property < ActiveRecord::Base
    include Discriminable

    discriminable_on :type
  end

  class Number < Property
    discriminable_value :number
  end

  class Text < Property
    discriminable_values :text, :string
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :properties do |t|
        t.string :type, default: "number"
      end
    end
  end

  def test_creation
    assert_equal "number", Number.create.type
    assert_equal "text", Text.create.type
  end

  def test_building
    assert_instance_of Text, Property.new(type: "string")
    assert_instance_of Number, Property.new(type: "number")
  end
end
