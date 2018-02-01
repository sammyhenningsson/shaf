module Shaf
  module JsonHtml

    def json2html(json)
      o = JSON.parse(json)
      "<pre><code>#{to_html(o)}</code></pre>"
    end

    private

    def to_html(obj, indent: 0, pre_indent: "")
      case obj
      when Array
        html_array(obj, indent, pre_indent)
      when Hash
        html_hash(obj, indent, pre_indent)
      else
        html_scalar(obj, indent, pre_indent)
      end
    end

    def html_array(a, indent, pre_indent)
      array_of_strings = a.map do |e|
        to_html(e, indent: indent + 1, pre_indent: indentation(indent + 1))
      end

      <<~EOS.chomp
        #{pre_indent}<span>[</span>
        #{array_of_strings.join(",\n")}
        #{indentation(indent)}<span>]</span>
      EOS
    end

    def html_hash(h, indent, pre_indent)
      <<~EOS.chomp
        #{pre_indent}<span>{</span>
        #{h.map { |k,v| sub_hash(k,v, indent + 1) }.join(",\n")},
        #{indentation(indent)}<span>}</span>
      EOS
    end

    def html_scalar(s, indent, pre_indent)
      q = around(s)
      format "%s%s%s%s", pre_indent, q, s, q
    end

    def sub_hash(key, value, indent)
      if key == 'href'
        %Q(#{indentation(indent)}"#{key}"<span>:</span> <a href="#{value}">#{value}</a>)
      else
        "#{indentation(indent)}\"#{key}\"<span>:</span> #{to_html(value, indent: indent) }"
      end
    end

    def indentation(i)
      "  " * i
    end

    def around(obj)
      return '"' if obj.is_a? String
      ""
    end

  end
end
