require 'shaf/generator/migration/type'

module Shaf
  module Generator
    module Migration
      module Types
        class << self
          def add(name, **kwargs)
            Type.new(name, **kwargs).tap do |type|
              types[type.name] = type
            end
          end

          def find(str)
            name, _ = str.to_s.split(',', 2)
            types[name.to_sym]
          end

          def all
            types.values
          end

          private

          def types
            @types ||= {}
          end

          def clear
            @types.clear if defined? @types
          end
        end
      end

      Types.add :integer,        create_template: 'Integer :%s',                 alter_template: 'add_column :%s, Integer'
      Types.add :varchar,        create_template: 'String %s',                   alter_template: 'add_column :%s, String'
      Types.add :string,         create_template: 'String :%s',                  alter_template: 'add_column :%s, String'
      Types.add :text,           create_template: 'String :%s, text: true',      alter_template: 'add_column :%s, String, text: true'
      Types.add :blob,           create_template: 'File :%s',                    alter_template: 'add_column :%s, File'
      Types.add :bigint,         create_template: 'Bignum :%s',                  alter_template: 'add_column :%s, Bignum'
      Types.add :double,         create_template: 'Float :%s',                   alter_template: 'add_column :%s, Float'
      Types.add :numeric,        create_template: 'BigDecimal :%s',              alter_template: 'add_column :%s, BigDecimal'
      Types.add :date,           create_template: 'Date :%s',                    alter_template: 'add_column :%s, Date'
      Types.add :timestamp,      create_template: 'DateTime :%s',                alter_template: 'add_column :%s, DateTime'
      Types.add :time,           create_template: 'Time :%s',                    alter_template: 'add_column :%s, Time'
      Types.add :bool,           create_template: 'TrueClass :%s',               alter_template: 'add_column :%s, TrueClass'
      Types.add :boolean,        create_template: 'TrueClass :%s',               alter_template: 'add_column :%s, TrueClass'
      Types.add :index,          create_template: 'index :%s, unique: true',     alter_template: 'add_index :%s'

      Types.add :foreign_key,
        create_template: 'foreign_key :%s, :%s',
        alter_template: 'add_foreign_key :%s, :%s',
        validator: ->(type, *args) {
          table = args[1]
          break if ::DB.table_exists?(table)
          ["Foreign key table '#{table}' does not exist!"]
        }
    end
  end
end
