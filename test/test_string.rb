# frozen_string_literal: true

require "helper"

class TestOn < Case
  class Property < DiscriminableModel
    discriminable_attribute :type, number: "Number", %i[text string] => "Text"
  end

  class Number < Property; end
  class Text < Property; end

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
