# frozen_string_literal: true

require 'net/http'
require 'tempfile'
require 'uri'
require 'csv'

module Shaf
  module ApiDoc
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

        def [](key)
          relations[key]
        end

        def []=(key, value)
          relations[key] = value
        end

        def add(link_relation)
          relations[link_relation.name] = link_relation
        end

        def load_iana
          csv.each do |name, desc, ref, notes|
            next if name == 'Relation Name'
            add LinkRelation.new(name, desc, ref, notes)
          end
        end

        private

        def relations
          @relations ||= {}
        end

        def tmp_file_name
          File.join(Dir.tmpdir, 'shaf_iana_link_relations')
        end

        def csv
          if File.readable? tmp_file_name
            content = File.read(tmp_file_name)
            return CSV.new(content)
          end

          response = Net::HTTP.get_response(IANA_URL)

          if response.code.to_i == 200
            content = response.body
            File.open(tmp_file_name, 'w') { |file| file.write(content) }
            CSV.new(content)
          else
            Utils.iana_link_relations_csv
          end
        end
      end
    end
  end
end
