# frozen_string_literal: true

require "active_record"

class Order < ActiveRecord::Base
  include Discriminable

  enum state: { open: 0, completed: 1 }

  uses_type_column :state, discriminate_types: states.keys do |state|
    case state
    when states[:open] then Cart
    else Order
    end
  end
end

class Cart < Order
end
