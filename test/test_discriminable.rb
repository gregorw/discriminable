# frozen_string_literal: true

require "test_helper"
require "setup_orders"

class TestDiscriminable < Test
  def test_that_it_has_a_version_number
    refute_nil ::Discriminable::VERSION
  end

  class ChildCount < Test
    def setup
      Order.create! state: :completed
      Cart.create!
    end

    def test_count
      assert_equal 1, Cart.count
    end

    def test_scopes
      assert_equal 1, Order.open.count
    end
  end
end
