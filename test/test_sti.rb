# frozen_string_literal: true

require "test_helper"
require "active_record"

class Order < ActiveRecord::Base
end

class Cart < Order
end

class TestDiscriminable < Test
  def setup
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :type
      end
    end

    Order.create!
    Cart.create!
  end

  def test_count
    assert_equal 1, Cart.count
    assert_equal 2, Order.count
  end

  def test_scopes
    assert_instance_of Cart, Cart.first
    assert_instance_of Order, Order.first
  end
end

class Initialization < Test
  def test_order
    refute_predicate Order.new, :changed?
  end

  def test_cart
    assert_predicate Cart.new, :changed?
  end
end
