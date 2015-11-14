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
    # ...
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options.keys.sort == [:foreign_key, :primary_key, :class_name].sort
      @foreign_key = options[:foreign_key]
      @primary_key = options[:primary_key]
      @class_name = options[:class_name]
    else
      @foreign_key = "#{name.downcase}_id".to_sym
      @primary_key = "id".to_sym
      @class_name = name.camelcase
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options.keys.sort == [:foreign_key, :primary_key, :class_name].sort
      @foreign_key = options[:foreign_key]
      @primary_key = options[:primary_key]
      @class_name = options[:class_name]
    else
      @foreign_key = "#{self_class_name.downcase}_id".to_sym
      @primary_key = "id".to_sym
      @class_name = name.camelcase.singularize
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
