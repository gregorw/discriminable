# frozen_string_literal: true

require_relative "discriminable/version"
require 'active_support'

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
# class MyModel < ActiveRecord::Base
#   include Discriminable
#
#   use_type_column :foobar, discriminate_types: [:rad, :cool] do |my_foobar|
#     my_foobar == 'rad' ? RadtasticModel : BoringModel
#   end
# end
#
module Discriminable
  extend ActiveSupport::Concern

  included do
    class_attribute :type_column, instance_writer: false
    class_attribute :discriminator, instance_writer: false
    class_attribute :discriminate_types, instance_writer: false
  end

  # Specify the column to use for discrimination.
  module ClassMethods
    def uses_type_column(type_column, discriminate_types: [], &block)
      raise "Subclasses should not override .uses_type_column" unless base_class?

      self.type_column = type_column.to_sym
      self.discriminator = block
      self.discriminate_types = discriminate_types
    end

    def finder_needs_type_condition?
      !base_class? && discriminate_types.present?
    end

    def sti_name
      discriminate_type_for_klass(self)
    end

    def inheritance_column
      type_column.to_s
    end

    def sti_type?
      false
    end

    protected

    def base_class?
      self == base_class
    end

    private

    # We don't want to let this interface attempt to set type on create/new
    # the #ensure_proper_type method will handle it for now.
    def populatable_scope_attributes
      scope_attributes.stringify_keys.reject { |k| k == type_column.to_s }
    end

    def discriminate_type_for_klass(klass)
      discriminate_types.each_with_object(Multimap.new) { |type, types| types[klass_for_type(type)] = type }[klass]
    end

    # calls like Model.find(5) return the correct types.
    def discriminate_class_for_record(record)
      klass_for_type(record[type_column.to_s])
    end

    # Creates instances of the appropriate type based on the type attribute. We need to override this so
    # calls like create return an appropriately typed model.
    def subclass_from_attributes(attributes)
      klass = klass_for_type(attributes[type_column])
      klass == self ? nil : klass
    end

    # If attributes exist and contain the type column we want to use the
    # attributes to build the custom subtype.
    def subclass_from_attributes?(attributes)
      attributes.present? && attributes.key?(type_column)
    end

    def klass_for_type(type)
      discriminator.call(type)
    end
  end

  def populate_with_current_scope_attributes
    return unless self.class.scope_attributes?

    self.class.send(:populatable_scope_attributes).each do |att, value|
      send("#{att}=", value) if respond_to?("#{att}=")
    end
  end

  def ensure_proper_type
    klass = self.class
    return unless klass.finder_needs_type_condition? && klass.sti_name.count == 1

    write_attribute(klass.inheritance_column, klass.sti_name.first)
  end
end
