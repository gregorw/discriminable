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
    class_attribute :discriminable_inverse, instance_writer: false
  end

  # Specify the column to use for discrimination.
  module ClassMethods
    def discriminable(**options)
      raise "Subclasses should not override .discriminable" unless base_class?

      discriminator, map = options.first

      self.discriminable_map = map.with_indifferent_access
      self.discriminable_inverse = map.invert
      self.inheritance_column = discriminator.to_s
    end

    def sti_name
      discriminable_inverse[name]
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

      value = base_class.type_for_attribute(inheritance_column).cast(attrs[inheritance_column])
      sti_class_for(value)
    end
  end
end
