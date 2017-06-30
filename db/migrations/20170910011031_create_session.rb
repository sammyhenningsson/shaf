Sequel.migration do
  change do
    create_table(:sessions) do
      primary_key :id
      Integer   :user_id,             null: false
      String    :auth_token_digest,   null: false
      DateTime  :created_at,          null: false
      DateTime  :expire_at,           null: false
      index     :user_id,             unique: true
      index     :auth_token_digest,   unique: true
    end

  end
end
