# frozen_string_literal: true

require_relative "discriminable/version"
require "active_support"

# Source: https://gist.github.com/rlburkes/798e186acb2f93e787a5
#
# Wouldn't it be great if you could have STI like functionality
# without needing to encode strings of class names in the database?
# Well today is your lucky day! Discriminable Model is here to help.
#
# Simply specify your models desired type column, and provide a block to
# do the discrimination. If you want the whole STI-esque shebang of properly
# typed finder methods you can supply an array of 'discriminate_types' that will
# be used to apply an appropriate type.
#
# class Customer < ActiveRecord::Base
#   include Discriminable
#
#   discriminable_attribute :state
# end
#
module Discriminable
  extend ActiveSupport::Concern

  included do
    class_attribute :_discriminable_map, instance_writer: false
    class_attribute :_discriminable_inverse_map, instance_writer: false
    class_attribute :_preloaded, instance_writer: false
  end

  # Add some docs
  module ClassMethods
    # When dealing with legacy databases or databases that are shared by third-party systems,
    # the classic Rails STI approach with type column and class names in the database is not always possible.
    # This is where `discriminable_attribute` comes in. It allows you to use a different attribute with a user
    # defined value / class name mapping.
    #
    # Example:
    #
    # class Company < ActiveRecord::Base
    #   discriminable_attribute :priority, 1 => "PriorityCustomer", [2, 3] => "Customer"
    # end
    def discriminable_attribute(attribute, **map)
      raise "Subclasses are not allowed to override .discriminable_attribute" unless base_class?

      # E.g. { value: "ClassName" }
      self._discriminable_map = flatten_keys(map).with_indifferent_access

      # Use first key as default discriminator
      # { a: "C", b: "C" }.invert => { "C" => :b }
      # { a: "C", b: "C" }.to_a.reverse.to_h.invert => { "C" => :a }
      # E.g. { "ClassName" => :value }
      self._discriminable_inverse_map = map.to_a.reverse.to_h.invert

      attribute = attribute.to_s
      self.inheritance_column = attribute_aliases[attribute] || attribute
    end

    # This is the value of the discriminable attribute
    def sti_name
      _discriminable_inverse_map[super]
    end

    # Returns the value to be stored in the inheritance column for STI.
    def sti_name_default
      store_full_sti_class && store_full_class_name ? name : name.demodulize
    end

    def sti_names
      ([self] + descendants).flat_map(&:sti_values)
    end

    def type_condition(table = arel_table)
      return super unless sti_values.present?

      sti_column = table[inheritance_column]
      predicate_builder.build(sti_column, sti_names)
    end

    def sti_class_for(value)
      return self unless (type_name = _discriminable_map[value])

      super type_name
    end

    def sti_values
      _discriminable_map.select do |sti_value, class_name|
        sti_value if class_name == sti_name_default
      end.keys.flatten
    end

    # See https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance
    def descendants
      unless _preloaded
        _discriminable_map.values.flatten.each do |klass|
          klass&.constantize
        rescue NameError
          # Class name could not be autoloaded / constantized.
        end
        self._preloaded = true
      end

      super
    end

    private

    # We want to support mapping multiple values to a class name at once.
    # Therefore we need to flatten the multiple keys. I.e. change
    # { 1 => "PriorityCustomer", [2, 3] => "Customer" }
    # to
    # { 1 => "PriorityCustomer", 2 => "Customer", 3 => "Customer" }
    def flatten_keys(hash)
      hash.keys.select { |key| key.is_a?(Array) }.each do |values|
        values.each do |value|
          hash[value] = hash[values]
        end
        hash.delete(values)
      end
      hash
    end

    # See active_record/inheritance.rb
    def subclass_from_attributes(attrs)
      attrs = attrs.to_h if attrs.respond_to?(:permitted?)
      return unless attrs.is_a?(Hash)

      value = _discriminable_value(attrs)
      sti_class_for(value)
    end

    def _discriminable_value(attrs)
      attrs = attrs.with_indifferent_access
      value = attrs[inheritance_column]
      value ||= attrs[attribute_aliases.invert[inheritance_column]]
      base_class.type_for_attribute(inheritance_column).cast(value)
    end
  end
end
