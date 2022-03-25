# frozen_string_literal: true

require "test_helper"
require "setup_orders"

class TestDiscriminable < Test
  ActiveRecord::Schema.define do
    create_table :orders do |t|
      t.integer :state, limit: 1, default: 0
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Discriminable::VERSION
  end

  class ChildCount < Test
    def setup
      Order.create! state: :completed
      Cart.create!
    end

    def teardown
      Order.delete_all
    end

    def test_count
      assert_equal 2, Order.count
      assert_equal 1, Cart.count
      assert_instance_of Cart, Cart.first
    end

    def test_scopes
      assert_equal 2, Order.count
      assert_equal 1, Order.open.count
      assert_instance_of Cart, Order.open.first
    end
  end

  class Initialization < Test
    def test_order
      refute_predicate Order.new, :changed?
    end

    def test_cart
      assert_predicate Cart.new, :changed?
      assert_predicate Cart.new, :open?
    end
  end
end
