class DocumentationSerializer < BaseSerializer
  model Shaf::ResourceDoc

  link :self do
    options[:path]
  end

  link :up do
    next unless options[:rel] || options[:attribute]
    documentation_path(resource.name)
  end

  post_serialize do |hash|
    if rel = options[:rel]
      hash[rel] = resource.link(rel)
    elsif attr = options[:attribute]
      hash[attr] = resource.attribute(attr)
    else
      hash[:attributes] = resource.attributes
      hash[:rels] = resource.links
      hash[:embeds] = resource.embeds
    end
  end
end
