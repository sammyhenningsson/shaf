# frozen_string_literal: true

module Shaf
  module JsonHtml
    STRUCTURAL_PATTERN = /^[\[\]\{\}:,]$/.freeze

    def json2html(json)
      as_html JSON.parse(json)
    end

    def as_html(obj)
      "<pre><code>#{to_html(obj)}</code></pre>"
    end

    private

    def to_html(obj, indent: 0, pre_indent: "")
      case obj
      when Array
        html_array(obj, indent, pre_indent)
      when Hash
        html_hash(obj, indent, pre_indent)
      else
        html_scalar(obj, pre_indent)
      end
    end

    def html_array(a, indent, pre_indent)
      array_of_strings = a.map do |e|
        to_html(e, indent: indent + 1, pre_indent: indentation(indent + 1))
      end

      <<~EOS.chomp
        #{pre_indent}#{span '['}
        #{array_of_strings.join(item_separator)}
        #{indentation(indent)}#{span ']'}
      EOS
    end

    def html_hash(h, indent, pre_indent)
      <<~EOS.chomp
        #{pre_indent}#{span '{'}
        #{h.map { |k,v| sub_hash(k,v, indent + 1) }.join(item_separator)}#{item_separator}
        #{indentation(indent)}#{span '}'}
      EOS
    end

    def html_scalar(s, pre_indent)
      format '%s%s', pre_indent, span(s)
    end

    def sub_hash(key, value, indent)
	  left_side = format '%s%s%s ', indentation(indent), quoted(key), span(':')
      left_side +
        if key.to_s == 'href'
          link(value)
        else
          to_html(value, indent: indent)
        end
    end

    def indentation(i)
      "  " * i
    end

    def quoted(obj)
      case obj
      when STRUCTURAL_PATTERN
        obj
      when String, Symbol
        format '"%s"', obj
      when NilClass
        'null'
      else
        obj
      end
    end

    def link(href)
      format '<a href="%s">%s</a>', href, quoted(href)
    end

    def span(value)
      clazz = span_class(value)
      value = quoted(value)
      format '<span class="%s">%s</span>', clazz, value
    end

    def span_class(obj)
      case obj
      when TrueClass, FalseClass
        'boolean'
      when NilClass
        'null'
      when Numeric
        'number'
      when STRUCTURAL_PATTERN
        'structural'
      else
        'string'
      end
    end

    def item_separator
      "#{span ','}\n"
    end
  end
end
