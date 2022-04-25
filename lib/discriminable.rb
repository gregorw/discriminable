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
#   discriminable state: { lead: "Lead" }
# end
#
module Discriminable
  extend ActiveSupport::Concern

  included do
    class_attribute :discriminable_map, instance_writer: false
    class_attribute :discriminable_inverse_map, instance_writer: false
    class_attribute :discriminable_values, instance_writer: false

    # Rails 5 support
    unless method_defined? :base_class?
      def self.base_class?
        base_class == self
      end
    end
  end

  # Specify the column to use for discrimination.
  module ClassMethods
    def discriminable(**options)
      raise "Subclasses should not override .discriminable" unless base_class?

      attribute, map = options.first

      # E.g. { value: "ClassName" }
      self.discriminable_map = map.with_indifferent_access

      # Use first key as default discriminator
      # { a: "C", b: "C" }.invert => { "C" => :b }
      # { a: "C", b: "C" }.to_a.reverse.to_h.invert => { "C" => :a }
      # E.g. { "ClassName" => :value }
      self.discriminable_inverse_map = map.to_a.reverse.to_h.invert

      attribute = attribute.to_s
      self.inheritance_column = attribute_aliases[attribute] || attribute
    end

    def discriminable_by(attribute)
      raise "Subclasses should not override .discriminable_by" unless base_class?

      self.discriminable_map ||= discriminable_map_memoized
      self.discriminable_inverse_map ||= discriminable_inverse_map_memoized

      attribute = attribute.to_s
      self.inheritance_column = attribute_aliases[attribute] || attribute
    end

    def discriminable_as(*values)
      raise "Only subclasses should specify .discriminable_as" if base_class?

      self.discriminable_values = values.map do |value|
        value.instance_of?(Symbol) ? value.to_s : value
      end
    end

    # This is the value of the discriminable attribute
    def sti_name
      discriminable_inverse_map[name]
    end

    def sti_class_for(value)
      return self unless (type_name = discriminable_map[value])

      super type_name
    end

    private

    # See active_record/inheritance.rb
    def subclass_from_attributes(attrs)
      attrs = attrs.to_h if attrs.respond_to?(:permitted?)
      return unless attrs.is_a?(Hash)

      value = discriminable_value(attrs)
      sti_class_for(value)
    end

    def discriminable_map_memoized
      Hash.new do |map, value|
        map[value] = descendants.detect { |d| d.discriminable_values.include? value }&.name
      end
    end

    def discriminable_inverse_map_memoized
      Hash.new do |map, value|
        map[value] = value.constantize.discriminable_values&.first
      end
    end

    def discriminable_value(attrs)
      attrs = attrs.with_indifferent_access
      value = attrs[inheritance_column]
      value ||= attrs[attribute_aliases.invert[inheritance_column]]
      base_class.type_for_attribute(inheritance_column).cast(value)
    end
  end
end
