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
#   discriminate_by state: { lead: "Lead" }
# end
#
module Discriminable
  extend ActiveSupport::Concern

  included do
    class_attribute :discriminator, instance_writer: false
    class_attribute :discriminate_map, instance_writer: false
    class_attribute :discriminate_inverse, instance_writer: false
  end

  # Specify the column to use for discrimination.
  module ClassMethods
    def discriminate_by(**options)
      raise "Subclasses should not override .discriminate_by" unless base_class?

      column, mapping = options.first

      self.discriminator = column
      self.discriminate_map = mapping.with_indifferent_access
      self.discriminate_inverse = mapping.invert
      self.inheritance_column = column.to_s
    end

    def sti_name
      discriminate_type_for_klass(self)
    end

    private

    def discriminate_type_for_klass(klass)
      discriminate_inverse[klass.name]
    end

    # calls like Model.find(5) return the correct types.
    def discriminate_class_for_record(record)
      discriminable_class(record)
    end

    # Creates instances of the appropriate type based on the type attribute. We need to override this so
    # calls like create return an appropriately typed model.
    def subclass_from_attributes(attributes)
      discriminable_class(attributes)
    end

    def discriminable_class(attributes)
      return unless attributes.present?

      value = base_class.type_for_attribute(inheritance_column).cast(attributes[inheritance_column])
      type_name = discriminate_map[value]

      return self unless type_name

      sti_class_for type_name
    end
  end
end
