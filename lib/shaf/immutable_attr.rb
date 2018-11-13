module Shaf
  module ImmutableAttr
    NON_DUPABLE_CLASSES = [
      NilClass,
      TrueClass,
      FalseClass,
      Symbol
    ]

    def self.dup(obj)
      return obj unless obj.respond_to? :dup
      return obj if NON_DUPABLE_CLASSES.include? obj.class
      obj.dup
    end

    def immutable_reader(*methods)
      methods.each do |method|
        define_method(method) do
          value = instance_variable_get(:"@#{method}")
          ImmutableAttr.dup(value)
        end
      end
    end

    def immutable_writer(*methods)
      methods.each do |method|
        define_method(:"#{method}=") do |value|
          instance_variable_set(
            :"@#{method}",
            ImmutableAttr.dup(value)
          )
        end
      end
    end

    def immutable_accessor(*methods)
      methods.each do |method|
        define_method(method) do
          value = instance_variable_get(:"@#{method}")
          ImmutableAttr.dup(value)
        end
        define_method(:"#{method}=") do |value|
          instance_variable_set(
            :"@#{method}",
            ImmutableAttr.dup(value)
          )
        end
      end
    end
  end
end
