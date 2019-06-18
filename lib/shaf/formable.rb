require 'shaf/formable/builder'

module Shaf
  module Formable
    # Deprecated legacy way of specifying forms inside models
    def form(&block)
      builder = Formable::Builder.new(&block)
      builder.forms.each do |f|
        next unless f.action
        getter = "#{f.action}_form"

        define_singleton_method(getter) { f }
        next unless instance_accessor = builder.instance_accessor_for(f)

        define_method(getter) do
          f.dup.tap do |fm|
            fm.resource = self
            fm.fill! if instance_accessor.prefill?
          end
        end
      end
    end

    # New way of writing forms in a separate class/file
    def forms_for(model_class, &block)
      builder = Formable::Builder.new(&block)
      builder.forms.each do |f|
        next unless f.action
        getter = "#{f.action}_form"

        model_class.define_singleton_method(getter) { f }
        next unless instance_accessor = builder.instance_accessor_for(f)

        b = proc do
          f.dup.tap do |fm|
            fm.resource = self
            fm.fill! if instance_accessor.prefill?
          end
        end

        if RUBY_VERSION < '2.5.0'
          # :send is needed as long as ruby 2.4 is support
          model_class.send(:define_method, getter, &b)
        else
          model_class.define_method(getter, &b)
        end
      end
    end
    alias form_for forms_for
  end
end
