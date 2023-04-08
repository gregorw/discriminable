# frozen_string_literal: true

require "helper"

class TestSti < Case
  class Order < ActiveRecord::Base
    self.store_full_sti_class = false
  end

  class Cart < Order; end
  class Invoice < Order; end

  def setup
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :type
      end
    end
  end

  def test_class_methods
    assert_equal Order.inheritance_column, "type"
    assert_equal Order.sti_name, "Order"
    assert_equal Cart.sti_name, "Cart"
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
    assert_instance_of Order, Order.first
    assert_instance_of Cart, Cart.first
    assert_instance_of Cart, Order.where(type: "Cart").first
  end

  def test_creating_and_building
    assert_instance_of Cart, Order.where(type: "Cart").build
    assert_instance_of Cart, Order.new(type: "Cart")
  end

  def test_changes
    refute_predicate Order.new, :changed?
    assert_empty Order.new.changes

    # See https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html
    assert_predicate Cart.new, :changed?
    assert_equal Cart.new.changes, "type" => [nil, "Cart"]
  end

  def test_becomes
    cart = Cart.create
    invoice = cart.becomes!(Invoice)
    invoice.save
    assert_instance_of Invoice, invoice
    assert_instance_of Invoice, invoice.reload
  end
end
