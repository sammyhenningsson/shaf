require 'shaf/formable/builder'

module Shaf
  module Formable
    def form(&block)
      builder = Formable::Builder.new(&block)
      builder.forms.each do |f|
        next unless f.action
        getter = "#{f.action}_form"

        define_singleton_method(getter) { f }
        next unless builder.instance_accessor_for? f

        define_method(getter) do
          f.dup.tap { |fm| fm.resource = self }
        end
      end
    end
  end
end
