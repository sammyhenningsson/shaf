require 'shaf/generator/migration/type'

module Shaf
  module Generator
    module Migration
      Type.add :integer,        create_template: 'Integer :%s',                 alter_template: 'add_column :%s, Integer'
      Type.add :varchar,        create_template: 'String %s',                   alter_template: 'add_column :%s, String'
      Type.add :string,         create_template: 'String :%s',                  alter_template: 'add_column :%s, String'
      Type.add :text,           create_template: 'String :%s, text: true',      alter_template: 'add_column :%s, String, text: true'
      Type.add :blob,           create_template: 'File :%s',                    alter_template: 'add_column :%s, File'
      Type.add :bigint,         create_template: 'Bignum :%s',                  alter_template: 'add_column :%s, Bignum'
      Type.add :double,         create_template: 'Float :%s',                   alter_template: 'add_column :%s, Float'
      Type.add :numeric,        create_template: 'BigDecimal :%s',              alter_template: 'add_column :%s, BigDecimal'
      Type.add :date,           create_template: 'Date :%s',                    alter_template: 'add_column :%s, Date'
      Type.add :timestamp,      create_template: 'DateTime :%s',                alter_template: 'add_column :%s, DateTime'
      Type.add :time,           create_template: 'Time :%s',                    alter_template: 'add_column :%s, Time'
      Type.add :bool,           create_template: 'TrueClass :%s',               alter_template: 'add_column :%s, TrueClass'
      Type.add :boolean,        create_template: 'TrueClass :%s',               alter_template: 'add_column :%s, TrueClass'
      Type.add :index,          create_template: 'index :%s, unique: true',     alter_template: 'add_index :%s'

      Type.add :foreign_key,
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
