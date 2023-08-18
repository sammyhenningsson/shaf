# frozen_string_literal: true

require 'net/http'
require 'tempfile'
require 'uri'
require 'csv'

module Shaf
  class LinkRelations
    class LinkRelation
      attr_reader :name, :description, :reference, :notes

      def initialize(name, description, reference, notes)
        @name = name.to_sym
        @description = description.freeze
        @reference = reference.freeze
        @notes = notes.freeze
      end
    end

    class << self
      IANA_URL = URI('https://www.iana.org/assignments/link-relations/link-relations-1.csv')

      def all
        relations.values
      end

      def get(key)
        load_iana
        relations[key.to_sym]
      end

      def add(link_relation)
        relations[link_relation.name.to_sym] = link_relation
      end

      private

      def load_iana
        return if @loaded

        iana_csv.each do |name, desc, ref, notes|
          next if name == 'Relation Name'
          add LinkRelation.new(name, desc, ref, notes)
        end

        @loaded = true
      end

      def relations
        @relations ||= {}
      end

      def tmp_file_name
        File.join(Dir.tmpdir, 'shaf_iana_link_relations')
      end

      def iana_csv
        CSV.new(iana_links)
      end

      def iana_links
        return File.read(tmp_file_name) if File.readable? tmp_file_name

        response = Net::HTTP.get_response(IANA_URL)

        if response.code.to_i == 200
          response.body.tap do |content|
            File.open(tmp_file_name, 'w') { |file| file.write(content) }
          end
        else
          Utils.iana_link_relations
        end
      end
    end
  end
end
