# frozen_string_literal: true

require "helper"

class TestBoolean < Case
  class Response < ActiveRecord::Base
    include Discriminable

    discriminable affirmative: { true => "TestBoolean::Yes" }
  end

  class Yes < Response
  end

  def setup
    ActiveRecord::Schema.define do
      create_table :responses do |t|
        t.boolean :affirmative, null: false, default: false
      end
    end
  end

  def test_class_methods
    assert_equal Response.inheritance_column, "affirmative"
    assert_nil Response.sti_name
    assert_equal Yes.sti_name, true
  end

  def test_count
    Response.create!
    Yes.create!
    assert_equal 2, Response.count
    assert_equal 1, Response.where(affirmative: true).count
    assert_equal 1, Yes.count
  end

  def test_kind
    Response.create!
    Yes.create!
    assert_instance_of TestBoolean::Response, Response.where(affirmative: false).first
    assert_instance_of TestBoolean::Yes, Response.where(affirmative: true).first
    assert_instance_of TestBoolean::Yes, Response.where(affirmative: true).build
    # assert_instance_of TestBoolean::Yes, Response.create(affirmative: true)
    assert_instance_of TestBoolean::Yes, Yes.first
  end

  def test_new
    refute_predicate Response.new, :changed?
    assert_equal Response.new.changes, {}

    assert_predicate Yes.new, :changed?
    assert_predicate Yes.new, :affirmative?
    assert_equal Yes.new.changes, { "affirmative" => [false, true] }
  end
end
