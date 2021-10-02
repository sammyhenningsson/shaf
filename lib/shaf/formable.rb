require 'shaf/formable/builder'

module Shaf
  module Formable
    def self.add_class_reader(clazz, name, form)
      clazz.define_singleton_method(name) { form.dup }
    end

    def self.add_instance_reader(clazz, name, form, prefill)
      clazz.define_method(name) do
        form.dup.tap do |f|
          f.resource = self
          f.fill! if prefill
        end
      end
    end

    def forms_for(clazz, &block)
      builder = Formable::Builder.new(&block)
      builder.forms.each do |form_wrapper|
        method_name = form_wrapper.method_name
        next unless method_name

        form = form_wrapper.form

        Formable.add_class_reader(clazz, method_name, form)
        next unless form_wrapper.instance_accessor?

        Formable.add_instance_reader(clazz, method_name, form, form_wrapper.prefill?)
      end
    end
    alias form_for forms_for
  end
end
