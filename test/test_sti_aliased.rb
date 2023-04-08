# frozen_string_literal: true

require "helper"

class TestStiAliased < Case
  class Order < ActiveRecord::Base
    self.inheritance_column = "type_with_some_postfix"
    alias_attribute :type, :type_with_some_postfix
  end

  class Cart < Order; end

  def setup
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :type_with_some_postfix
      end
    end
  end

  def test_class_methods
    assert_equal Order.inheritance_column, "type_with_some_postfix"
    assert_equal Order.sti_name, "TestStiAliased::Order"
    assert_equal Cart.sti_name, "TestStiAliased::Cart"
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
    assert_instance_of TestStiAliased::Order, Order.first
    assert_instance_of TestStiAliased::Cart, Cart.first
    assert_instance_of TestStiAliased::Cart, Order.where(type: "TestStiAliased::Cart").first
  end

  def test_creating_and_building
    assert_instance_of TestStiAliased::Cart, Order.new(type_with_some_postfix: "TestStiAliased::Cart")
    assert_instance_of TestStiAliased::Cart, Order.where(type: "TestStiAliased::Cart").build

    skip "This is not supported"
    assert_instance_of TestStiAliased::Cart, Order.new(type: "TestStiAliased::Cart")
  end

  def test_changes
    refute_predicate Order.new, :changed?
    assert_empty Order.new.changes

    # See https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html
    assert_predicate Cart.new, :changed?
    assert_equal({ "type_with_some_postfix" => [nil, "TestStiAliased::Cart"] }, Cart.new.changes)
  end
end
