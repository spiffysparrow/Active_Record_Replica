require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{name.downcase}_id".to_sym
    end

    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = "id".to_sym
    end

    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.camelcase.singularize
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{self_class_name.downcase}_id".to_sym
    end

    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = "id".to_sym
    end

    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.camelcase.singularize
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)
    define_method( name.to_sym ) do
      foreign_key_val = send( options.foreign_key )
      return_class = options.model_class
      owener_objects = return_class.where(id: foreign_key_val)
      owener_objects.first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.to_s, options)
    define_method( name.to_sym ) do
      return_class = options.model_class
      p "-----------"
      p self
      p name
      p options
      p "WHERE #{options.foreign_key}, #{id}"
      owener_objects = return_class.where(options.foreign_key id)
      owener_objects
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
