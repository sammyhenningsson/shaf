require 'sinatra/base'

module Shaf
  module ControllerHooks
    def before_action(method_name = nil, **options, &block)
      __action_hook(:before, method_name, block, options)
    end

    def after_action(method_name = nil, **options, &block)
      __action_hook(:after, method_name, block, options)
    end

    private

    def __action_hook(hook, method_name, block, **options)
      only = Array(options[:only]) if options.key? :only
      except = Array(options[:except]) if options.key? :except

      path_helpers.each do |helper|
        next if only && !only.include?(helper)
        next if except&.include? helper
        pattern = __path_pattern(helper)

        if method_name
          send(hook, pattern) { send(method_name) }
        elsif block
          send(hook, pattern, &block)
        else
          log.warn <<~RUBY
            #{hook}_action without block (options: #{options}).
            Specify method or pass a block!
          RUBY
        end
      end
    end

    def __path_pattern(path_helper)
      uri_helper = path_helper.to_s.sub(/path\Z/, 'uri')
      template_method = "#{uri_helper}_template".to_sym
      template = send template_method
      str = template.gsub(%r{:[^/]*}, '\w+')
      Regexp.new("#{str}/?")
    end
  end

  Sinatra.register ControllerHooks
end
