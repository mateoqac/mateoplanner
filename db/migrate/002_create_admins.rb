ROM::SQL.migration do
  change do
    create_table :admins do
      primary_key :id
      String :email, null: false, unique: true
      String :password_digest, null: false

      DateTime :created_at
      DateTime :updated_at
    end

    add_index :admins, :email, unique: true
  end
end
