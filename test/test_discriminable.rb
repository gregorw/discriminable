# frozen_string_literal: true

require "test_helper"
require "setup_orders"

class TestDiscriminable < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Discriminable::VERSION
  end

  def test_count
    Order.create! state: :completed
    Cart.create!
    assert_equal 1, Cart.count
  end
end
