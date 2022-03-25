# frozen_string_literal: true

class Case < Minitest::Test
  def teardown
    ActiveRecord::Base.connection.tap do |c|
      c.tables.each do |table|
        c.drop_table table
      end
    end
  end
end
