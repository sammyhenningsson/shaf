require 'shaf/formable/builder'

module Shaf
  module Formable
    def self.included(base)
      base.extend(ClassMethods)
    end

    def edit_form
      form = self.class.edit_form
      return unless form

      form.tap do |f|
        f.resource = self
      end
    end

    module ClassMethods
      attr_reader :create_form, :edit_form

      def form(&block)
        @create_form, @edit_form = Formable::Builder.call(block)
      end
    end
  end
end
