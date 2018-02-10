module Shaf
  module Generator
    class Serializer < Base
      identifier :serializer
      usage 'generate serializer MODEL_NAME'

      def call
        if name.empty?
          raise "Please provide a model name when using the serializer generator!"
        end

        create_serializer
        create_serializer_spec
        create_policy
      end

      def name
        args.first || ""
      end

      def plural_name
        Utils.pluralize(name)
      end

      def model_class_name
        "::#{name.capitalize}"
      end

      def policy_class_name
        "::#{name.capitalize}Policy"
      end

      def template
        'app/serializer.rb'
      end

      def spec_template
        'spec/serializer_spec.rb'
      end

      def target
        "app/serializers/#{name}.rb"
      end

      def spec_target
        "spec/serializers/#{name}_spec.rb"
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
        %w(up self 'create-form' 'edit-form' edit delete)
      end

      def links_with_doc
        [
          collection_link,
          self_link,
          new_link,
          edit_link,
          update_link,
          delete_link,
        ]
      end

      def collection_link
        link(
          rel: "up",
          desc: "Link to the collection of all #{plural_name}. " \
          "Send a POST request to this uri to create a new #{name}",
          uri: "/#{plural_name}",
          uri_helper: "#{plural_name}_uri"
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

      def new_link
        link(
          rel: "'create-form'",
          desc: "Link to a form to create a new #{name}",
          uri: "/#{plural_name}/form",
          uri_helper: "new_#{name}_uri"
        )
      end

      def edit_link
        link(
          rel: "'edit-form'",
          desc: "Link to a form to edit this resource",
          uri: "/#{plural_name}/5/edit",
          uri_helper: "edit_#{name}_uri(resource)"
        )
      end

      def update_link
        link(
          rel: "edit",
          desc: "Link to update this #{name}",
          method: "PUT",
          uri: "/#{plural_name}/5",
          uri_helper: "#{name}_uri(resource)"
        )
      end

      def delete_link
        link(
          rel: "delete",
          desc: "Link to delete this #{name}",
          method: "DELETE",
          uri: "/#{plural_name}/5",
          uri_helper: "#{name}_uri(resource)"
        )
      end

      def link(rel:, method: "GET", desc:, uri:, uri_helper:)
        <<~EOS.split("\n")
          # Auto generated doc:  
          # #{desc}.  
          # Method: #{method}  
          #{example(method, uri)}
          link :#{rel} do
            #{uri_helper}
          end
        EOS
      end

      def example(method, uri)
        method_args = ""
        case method
        when "POST"
          method_args = "\n#      -d@payload \\"
        when "PUT"
          method_args = "\n#      -X PUT -d@payload \\"
        when "DELETE"
          method_args = "\n#      -X DELETE \\"
        end

        <<~EOS
          # Example:
          # ```
          # curl -H "Accept: application/json" \\
          #      -H "Authorization: abcdef" \\#{method_args}
          #      #{uri}
          #```
        EOS
      end

      def embeds
        [:'edit-form']
      end

      def embeds_with_doc
        [
          <<~EOS.split("\n")
            # Auto generated doc:  
            # A form to edit this #{name}
            embed :'edit-form' do
              resource.edit_form.tap do |form|
                form.self_link = edit_#{name}_uri(resource)
                form.href = #{name}_uri(resource)
              end
            end
          EOS
        ]
      end

      def collection_with_doc
        <<~EOS.split("\n")
          collection of: '#{plural_name}' do
            link :self, #{plural_name}_uri
          
            embed :'create-form' do
              #{model_class_name}.create_form.tap do |form|
                form.self_link = new_#{name}_uri
                form.href = #{plural_name}_uri
              end
            end
          end
        EOS
      end

      def opts
        {
          name: name,
          class_name: name.capitalize,
          model_class_name: model_class_name,
          policy_class_name: policy_class_name,
          attributes: attributes,
          links: links,
          embeds: embeds,
          attributes_with_doc: attributes_with_doc,
          links_with_doc: links_with_doc,
          embeds_with_doc: embeds_with_doc,
          collection_with_doc: collection_with_doc,
        }
      end

      def create_policy
        policy_args = ["policy", name, *args[1..-1]]
        Generator::Factory.create(*policy_args).call
      end
    end
  end
end
