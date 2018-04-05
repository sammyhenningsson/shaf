module Shaf
  module Spec
    class SerializerSpec < Base
      register_spec_type self do |desc, args|
        next true if desc.to_s =~ /Serializer$/
        next unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'serializer'
      end
    end
  end
end
