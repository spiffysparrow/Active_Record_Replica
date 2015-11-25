require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_obj = self.send(through_name)
      return_obj = through_obj.send(source_name)
    end

    options = BelongsToOptions.new(name.to_s, {through: through_name, source: source_name})
    assoc_options(name, options)

  end
end
