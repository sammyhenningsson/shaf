module Shaf
  module Generator
    class Serializer < Base
      identifier :serializer
      usage 'generate serializer SERIALIZER_NAME'

      def call
        if name.empty?
          raise "Please provide a serializer name when using the serializer generator!"
        end

        puts "generating serializer #{name}.."
        create_serializer
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

      def target
        "app/serializers/#{name}.rb"
      end

      def create_serializer
        content = render(template, opts)
        write_output(target, content)
      end

      def attributes
        args[1..-1].map do |attr|
          [
            "# FIXME: Write documentation for attribute #{attr}",
            "attribute :#{attr}"
          ]
        end
      end

      def links
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
        [
          "# Auto generated doc:  ",
          "# #{desc}.  ",
          "# Method: #{method}  ",
        ] +
        example(method, uri) +
        [
          "link :#{rel} do",
          "  #{uri_helper}",
          "end",
        ]
      end

      def example(method, uri)
        ex = [
          "# Example:",
          "# ```",
          "# curl -H \"Accept: application/json\" \\",
          "#      -H \"Authorization: abcdef\" \\",
        ]

        case method
        when "POST"
          ex << "#      -d@payload \\"
        when "PUT"
          ex << "#      -X PUT -d@payload \\"
        when "DELETE"
          ex << "#      -X DELETE \\"
        end

        ex + ["#      #{uri}", "# ```"]
      end

      def collection
        [
          "collection of: '#{plural_name}' do",
          "  link :self, UriHelper.#{plural_name}_uri",
          "end",
        ]
      end

      def opts
        {
          name: name,
          class_name: name.capitalize,
          model_class_name: model_class_name,
          policy_class_name: policy_class_name,
          attributes: attributes,
          links: links,
          collection: collection
        }
      end
    end
  end
end
#
#     # The users username.
#     attribute :username
# 
#     # The users email address.
#     attribute :email
#     
#     # Link to this resource.  
#     # Method: GET  
#     # Example:  
#     #```
#     # curl -H "Accept: "application/vnd.api+json" \
#     #      -H "Authorization: "abcdef \
#     #      /api/users/5
#     #```
#     link :self do
#       user_uri(resource)
#     end
# 
#     # Link to update this resource.  
#     # Method: PUT  
#     # Example:  
#     #```
#     # curl -H "Accept: "application/vnd.api+json" \
#     #      -H "Authorization: "abcdef \
#     #      -X PUT -d '{"user": {"name": "Bengt Bengtsson"}}'
#     #      /api/users/5
#     #```
#     link :edit do
#       user_uri(resource)
#     end
# 
#     # Link to get a form for updating this resource.  
#     # Method: GET  
#     # Example:  
#     #```
#     # curl -H "Accept: "application/vnd.api+json" \
#     #      -H "Authorization: "abcdef \
#     #      /api/users/5/edit-form
#     #```
#     link :'edit-form' do
#       edit_user_uri(resource)
#     end
# 
#     # Link to remove this resource.  
#     # Method: DELETE  
#     # Example:  
#     #```
#     # curl -H "Accept: "application/vnd.api+json" \
#     #      -H "Authorization: "abcdef \
#     #      /api/users/5/edit-form
#     #```
#     link :delete do
#       user_uri(resource)
#     end
# 
#     collection of: 'users' do
#       link :self, UriHelper.users_uri
#     end
#   end
# end
