class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}")
      end
      define_method("#{name}=") do |new_val|
        instance_variable_set("@#{name}", new_val)
      end
    end
  end
end
