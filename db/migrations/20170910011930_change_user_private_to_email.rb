Sequel.migration do
  up do
    alter_table(:users) do
      drop_column   :private
      add_column    :email,      String
      add_index     :email,             unique: true
    end
  end

  down do
    alter_table(:users) do
      add_column :private,    TrueClass,       default: false
      drop_column :email
    end
  end
end
