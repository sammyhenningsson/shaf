require 'shaf/formable/builder'

module Shaf
  module Formable
    def self.add_class_reader(clazz, name, form)
      clazz.define_singleton_method(name) { form }
    end

    def self.add_instance_reader(clazz, name, form, prefill)
      clazz.define_method(name) do
        form.tap do |f|
          f.resource = self
          f.fill! if prefill
        end
      end
    end

    # Deprecated legacy way of specifying forms inside models
    def form(&block)
      forms_for(self, &block)
      return unless defined? $logger

      $logger.info <<~MSG


        DEPRECATED method ::form in #{self}
        Declare forms in a separate class extending Shaf::Formable with the class method forms_for!
      MSG
    end

    # New way of writing forms in a separate class/file
    def forms_for(clazz, &block)
      builder = Formable::Builder.new(&block)
      builder.forms.each do |form|
        next unless form.action
        method_name = "#{form.action}_form"

        Formable.add_class_reader(clazz, method_name, form.dup)

        if instance_accessor = builder.instance_accessor_for(form)
          prefill_form = instance_accessor.prefill?
          Formable.add_instance_reader(clazz, method_name, form.dup, prefill_form)
        end
      end
    end
    alias form_for forms_for
  end
end
