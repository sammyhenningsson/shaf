# frozen_string_literal: true

module Shaf
  module Spec
    class SystemSpec < Base
      register_spec_type self do |desc, args|
        next unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'system'
      end
    end
  end
end

