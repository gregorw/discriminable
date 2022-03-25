# frozen_string_literal: true

require "helper"
require "active_record"

class TestEnum < Case
  class Order < ActiveRecord::Base
    include Discriminable

    enum state: { open: 0, completed: 1 }

    uses_type_column :state, discriminate_types: states.keys do |state|
      case state
      when "open" then Cart
      else Order
      end
    end
  end

  class Cart < Order
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.integer :state, limit: 1, default: 0
      end
    end
  end

  def test_class_methods
    assert_equal "state", Order.inheritance_column
    assert_equal "completed", Order.sti_name
    assert_equal "open", Cart.sti_name
  end

  def test_count
    Order.create! state: :completed
    Cart.create!
    assert_equal 2, Order.count
    assert_equal 1, Order.open.count
    assert_equal 1, Cart.count
  end

  def test_kind
    Order.create! state: :completed
    Cart.create!
    assert_instance_of TestEnum::Order, Order.completed.first
    assert_instance_of TestEnum::Cart, Order.open.first
    # assert_instance_of TestEnum::Cart, Order.open.build
    # assert_instance_of TestEnum::Cart, Order.new(state: :open)
    assert_instance_of TestEnum::Cart, Cart.first
  end

  def test_new
    refute_predicate Order.new, :changed?
    assert_equal Order.new.changes, {}

    refute_predicate Cart.new, :changed? # Why is this the case?
    assert_predicate Cart.new, :open?
    assert_equal Cart.new.changes, {}
  end
end
