module Shaf
  module Generator
    class Serializer < Base
      identifier :serializer
      usage 'generate serializer MODEL_NAME [attribute[:type]] [..]'

      def call
        create_serializer
        create_serializer_spec if options[:specs]
        create_policy
        create_profile
      end

      def serializer_class_name
        "#{model_class_name}Serializer"
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

      def target_dir
        'api/serializers'
      end

      def target_name
        "#{name}_serializer.rb"
      end

      def spec_target
        target(directory: 'spec/serializers', name: "#{name}_serializer_spec.rb")
      end

      def policy_file
        File.join(['policies', namespace, "#{name}_policy"].compact)
      end

      def create_serializer
        content = render(template, opts)
        content = wrap_in_module(content, module_name)
        write_output(target, content)
      end

      def create_serializer_spec
        content = render(spec_template, opts)
        content = wrap_in_module(content, module_name, search: "describe #{serializer_class_name}")
        write_output(spec_target, content)
      end

      def attributes
        args[1..-1]
      end

      def attribute_names
        attributes.map { |arg| arg.split(':').first }
      end

      def attributes_with_doc
        attribute_names.map { |attr| ["attribute :#{attr}"] }
      end

      def link_relations
        %w(collection self edit-form doc:delete)
      end

      def profile_with_doc
        doc = <<~DOC
          # Adds a link to the '#{name}' profile and a curie. By default the
          # curie prefix is 'doc', use the `curie_prefix` keyword argument to
          # change this.
          # Note: the target of the profile link and the curie will be set to
          # `profile_uri('#{name}')` resp. `doc_curie_uri('#{name}')`. To
          # create links for external profiles or curies, delete the next line
          # and use `::link` and/or `::curie` instead.
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
          uri_helper: "#{plural_name}_uri",
          kwargs: {embed_depth: 0}
        )
      end

      def self_link
        link(
          rel: "self",
          uri_helper: "#{name}_uri(resource)"
        )
      end

      def edit_link
        link(
          rel: "edit-form",
          uri_helper: "edit_#{name}_uri(resource)"
        )
      end

      def delete_link
        link(
          rel: "delete",
          uri_helper: "#{name}_uri(resource)",
          kwargs: {curie: :doc}
        )
      end

      def create_link
        link(
          rel: "create-form",
          uri_helper: "new_#{name}_uri"
        )
      end

      def link(rel:, uri_helper:, kwargs: {})
        kwargs_str = kwargs.inject('') do |s, (k,v)|
          "#{s}, #{k}: #{Utils.symbol_or_quoted_string(v)}"
        end

        <<~EOS.split("\n")
          link #{Utils.symbol_string(rel)}#{kwargs_str} do
            #{uri_helper}
          end
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
          class_name: serializer_class_name,
          model_class_name: model_class_name,
          policy_class_name: policy_class_name,
          policy_file: policy_file,
          attribute_names: attribute_names,
          link_relations: link_relations,
          profile_with_doc: profile_with_doc,
          attributes_with_doc: attributes_with_doc,
          links_with_doc: links_with_doc,
          collection_with_doc: collection_with_doc
        }
      end

      def create_policy
        policy_args = ["policy", name_arg, *attribute_names]
        Generator::Factory.create(*policy_args, **options).call
      end

      def create_profile
        profile_args = ["profile", name_arg, *attributes]
        Generator::Factory.create(*profile_args, **options).call
      end
    end
  end
end
