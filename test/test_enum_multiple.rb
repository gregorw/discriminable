# frozen_string_literal: true

require "helper"

class TestEnumMultiple < Case
  class Order < ActiveRecord::Base
    include Discriminable

    enum state: { open: 0, completed: 1, invoiced: 2, reminded: 3 }
    discriminable state: {
      open: "TestEnumMultiple::Cart",
      invoiced: "TestEnumMultiple::Invoice",
      reminded: "TestEnumMultiple::Invoice"
    }
  end

  class Cart < Order
  end

  class Invoice < Order
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.integer :state, limit: 1, default: 0
      end
    end
  end

  def test_sti_name_default
    assert_equal Invoice.sti_name, :invoiced
  end

  def test_default_enum_type
    assert_predicate Invoice.new, :invoiced?
    assert_predicate Invoice.create, :invoiced?
    assert_predicate Invoice.reminded.create, :reminded?
  end
end
