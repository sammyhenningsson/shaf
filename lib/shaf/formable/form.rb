require 'shaf/formable/field'

module Shaf
  module Formable
    class Form

      DEFAULT_TYPE = 'application/json'

      attr_accessor :resource, :name, :title, :href, :type, :self_link
      attr_reader :fields

      def initialize(params = {})
        @name = params[:name]
        @title = params[:title]
        @method = params[:method] || 'POST'
        @type = params[:type] || DEFAULT_TYPE
        @fields = (params[:fields] || {}).map { |name, args| Field.new(name, args) }
      end

      def method=(m)
        @method = m.to_s.upcase
      end

      def method
        @method.to_s.upcase
      end

      def fields=(fields)
        @fields = fields.map { |name, args| Field.new(name, args) }
      end

      def add_field(name, opts)
        @fields << Field.new(name, opts)
      end

      def to_html
        form_element do
          [
            hidden_method_element,
            fields.map { |f| f.to_html }.join("\n"),
            submit_element,
          ].compact.join("\n")
        end
      end

      private

      def form_element
        [
          %Q(<form class="form" method=#{method == 'GET' ? 'GET' : 'POST'}#{href ? %Q( action="#{href.to_s}") : ''}>),
          block_given? ? yield : nil,
          "</form>",
        ].compact.join("\n")
      end

      def hidden_method_element
        return if ['GET', 'POST'].include?(method)
        %Q(<input type="hidden" name="_method" value="#{method}">)
      end

      def submit_element
        %Q(<div class="form--input-group"><input type="submit" class="button" value="Submit"</div>)
      end
    end
  end
end
