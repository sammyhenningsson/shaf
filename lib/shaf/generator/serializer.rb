module Shaf
  module Generator
    class Serializer < Base
      identifier :serializer
      usage 'generate serializer MODEL_NAME [attribute] [..]'

      def call
        create_serializer
        create_serializer_spec if options[:specs]
        create_policy
      end

      def name
        n = args.first || ""
        return n unless n.empty?
        raise Command::ArgumentError,
          "Please provide a model name when using the serializer generator!"
      end

      def plural_name
        Utils.pluralize(name)
      end

      def model_class_name
        Utils.model_name(name)
      end

      def policy_class_name
        "#{model_class_name}Policy"
      end

      def template
        'api/serializer.rb'
      end

      def spec_template
        'spec/serializer_spec.rb'
      end

      def target
        "api/serializers/#{name}_serializer.rb"
      end

      def spec_target
        "spec/serializers/#{name}_serializer_spec.rb"
      end

      def create_serializer
        content = render(template, opts)
        write_output(target, content)
      end

      def create_serializer_spec
        content = render(spec_template, opts)
        write_output(spec_target, content)
      end

      def attributes
        args[1..-1].map { |attr| ":#{attr}" }
      end

      def attributes_with_doc
        attributes.map do |attr|
          [
            "# FIXME: Write documentation for attribute #{attr}",
            "attribute #{attr}"
          ]
        end
      end

      def links
        %w(collection self edit-form doc:delete)
      end

      def profile_with_doc
        doc = <<~DOC
          # Adds a link to the '#{name}' profile and a curie. By default the
          # curie prefix is 'doc', use the `curie_prefix` keyword argument to
          # change this.
          # Note: the target of the profile link and the curie will be set to
          # `profile_uri('#{name}')` resp. `doc_curie_uri('#{name}')`. To
          # create links for external profiles or curies, use `::link` and/or
          # `::curie` instead.
        DOC

        doc.split("\n") << %Q(profile #{Utils.symbol_string(name)})
      end

      def links_with_doc
        [
          collection_link,
          self_link,
          edit_link,
          delete_link,
        ]
      end

      def collection_link
        link(
          rel: "collection",
          desc: "Link to the collection of all #{plural_name}. " \
          "Send a POST request to this uri to create a new #{name}",
          method: "GET or POST",
          uri: "/#{plural_name}",
          uri_helper: "#{plural_name}_uri",
          kwargs: ', embed_depth: 0'
        )
      end

      def self_link
        link(
          rel: "self",
          desc: "Link to this #{name}",
          uri: "/#{plural_name}/5",
          uri_helper: "#{name}_uri(resource)"
        )
      end

      def edit_link
        link(
          rel: "edit-form",
          desc: "Link to a form to edit this resource",
          uri: "/#{plural_name}/5/edit",
          uri_helper: "edit_#{name}_uri(resource)"
        )
      end

      def delete_link
        link(
          rel: "delete",
          desc: "Link to delete this #{name}",
          method: "DELETE",
          uri: "/#{plural_name}/5",
          uri_helper: "#{name}_uri(resource)",
          kwargs: ", curie: :doc"
        )
      end

      def create_link
        link(
          rel: "create-form",
          desc: "Link to a form used to create new #{name} resources",
          uri: "/#{plural_name}/form",
          uri_helper: "new_#{name}_uri"
        )
      end

      def link(rel:, method: "GET", desc:, uri:, uri_helper:, kwargs: "")
        <<~EOS.split("\n")
          # Auto generated doc:  
          # #{desc}.  
          # Method: #{method}  
          #{example(method, uri)}
          link #{Utils.symbol_string(rel)}#{kwargs} do
            #{uri_helper}
          end
        EOS
      end

      def example(method, uri)
        curl_args = +'-H "Authorization: abcdef \\"'
        case method
        when "POST"
          curl_args << "\n#      -d@payload \\"
        when "PUT"
          curl_args << "\n#      -X PUT -d@payload \\"
        when "DELETE"
          curl_args << "\n#      -X DELETE \\"
        end

        <<~EOS.chomp
          # Example:
          # ```
          # curl -H "Accept: application/hal+json" \\
          #      #{curl_args}
          #      #{uri}
          #```
        EOS
      end

      def collection_with_doc
        <<~EOS.split("\n")
          collection of: '#{plural_name}' do
            curie(:doc) { doc_curie_uri('#{name}') }

            link :self, #{plural_name}_uri
            link :up, root_uri

            #{create_link.join("\n  ")}
          end
        EOS
      end

      def opts
        {
          name: name,
          class_name: "#{model_class_name}Serializer",
          model_class_name: model_class_name,
          policy_class_name: policy_class_name,
          policy_name: "#{name}_policy",
          attributes: attributes,
          profile_with_doc: profile_with_doc,
          links: links,
          attributes_with_doc: attributes_with_doc,
          links_with_doc: links_with_doc,
          collection_with_doc: collection_with_doc
        }
      end

      def create_policy
        policy_args = ["policy", name, *args[1..-1]]
        Generator::Factory.create(*policy_args, **options).call
      end
    end
  end
end
