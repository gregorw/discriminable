# frozen_string_literal: true

require "helper"
require "active_record"

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

    Order.create!
    Cart.create!
  end

  def test_count
    assert_equal 2, Order.count
    assert_equal 1, Cart.count
  end

  def test_kind
    assert_instance_of TestSti::Order, Order.first
    assert_instance_of TestSti::Cart, Cart.first
    assert_instance_of TestSti::Cart, Order.where(type: 'TestSti::Cart').first
  end

  def test_new
    refute_predicate Order.new, :changed?
    assert_equal Order.new.changes, {}

    assert_predicate Cart.new, :changed?
    assert_equal Cart.new.changes, 'type' => [nil, "TestSti::Cart"]
  end
end
