# frozen_string_literal: true

require "helper"

class TestSti < Case
  class Order < ActiveRecord::Base
  end

  class Cart < Order
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :type
      end
    end
  end

  def test_class_methods
    assert_equal Order.inheritance_column, "type"
    assert_equal Order.sti_name, "TestSti::Order"
    assert_equal Cart.sti_name, "TestSti::Cart"
  end

  def test_count
    Order.create
    Cart.create
    assert_equal 2, Order.count
    assert_equal 1, Cart.count
  end

  def test_loading
    Order.create
    Cart.create
    assert_instance_of TestSti::Order, Order.first
    assert_instance_of TestSti::Cart, Cart.first
    assert_instance_of TestSti::Cart, Order.where(type: "TestSti::Cart").first
  end

  def test_creating_and_building
    assert_instance_of TestSti::Cart, Order.where(type: "TestSti::Cart").build
    assert_instance_of TestSti::Cart, Order.new(type: "TestSti::Cart")
  end

  def test_changes
    refute_predicate Order.new, :changed?
    assert_empty Order.new.changes

    # See https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html
    assert_predicate Cart.new, :changed?
    assert_equal Cart.new.changes, "type" => [nil, "TestSti::Cart"]
  end
end
