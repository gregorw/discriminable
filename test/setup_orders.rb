# frozen_string_literal: true

require "active_record"

ActiveRecord::Schema.define do
  create_table :orders, force: true do |t|
    t.integer :state, limit: 1, default: 0
  end
end

class Order < ActiveRecord::Base
  include Discriminable

  enum state: { open: 0, completed: 1 }

  uses_type_column :state, discriminate_types: states.keys do |state|
    case state&.to_sym
    when :open then Cart
    else Order
    end
  end
end

class Cart < Order
end
