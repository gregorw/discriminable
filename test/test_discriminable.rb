# frozen_string_literal: true

require "helper"

class TestDiscriminable < Case
  def test_that_it_has_a_version_number
    refute_nil ::Discriminable::VERSION
  end
end
