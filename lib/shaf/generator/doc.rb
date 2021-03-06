# frozen_string_literal: true

module Shaf
  module Generator
    class Doc < Base
      identifier %r{\Adoc(\b|umentation)\Z}
      usage 'generate doc [SERIALIZER_NAME] [..]'

      def call
        require 'shaf/yard'
        name = String(args[0]).strip
        Shaf::Yard::Parser.call(name: name)
        YARD::Templates::Engine.render(template: :api_doc, format: :html)
      end
    end
  end
end
