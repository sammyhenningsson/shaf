Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username,         null: false
      String :password_digest,  null: false
      String :auth_token_digest
      TrueClass :private,       default: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
