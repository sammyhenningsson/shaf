require 'yaml'

module Shaf
  class ResourceDoc
    class << self
      def find(name)
        unless docs[name]
          properties = load(name) or return
          docs[name] = new(name, properties)
        end
        docs[name]
      end

      def find!(name)
        find(name) or raise(Errors::NotFoundError, "No documentation for #{name}")
      end

      private

      def docs
        @docs ||= {}
      end

      def load(name)
        file = File.join(Settings.documents_dir, "#{name}.yml")
        return YAML.load(File.read(file)) if File.exist? file
      end
    end
    
    attr_reader :name, :attributes, :links, :curies, :embeds

    def initialize(name, properties = {})
      @name       = name
      @attributes = properties.fetch('attributes', {})
      @links      = properties.fetch('links', {})
      @curies     = properties.fetch('curies', {})
      @embeds     = properties.fetch('embeds', {})
    end

    def to_s
      JSON.pretty_generate(
        attributes: attributes,
        links: links,
        curies: curies,
        embeds: embeds,
      )
    end

    def attribute(attr)
      attr_doc = attributes[attr.to_s]
      return attr_doc if attr_doc
      raise Errors::NotFoundError,
        "No documentation for #{name} attribute '#{attr}'"
    end

    def link(rel)
      link_doc = links[rel.to_s]
      return link_doc if link_doc
      raise Errors::NotFoundError,
        "No documentation for #{name} link relation '#{rel}'"
    end

    def embedded(name)
      embed_doc = embeds[name.to_s]
      return embed_doc if embed_doc
      raise Errors::NotFoundError,
        "No documentation for #{name} embedded '#{name}'"
    end
  end
end
