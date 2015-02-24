Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :username, size: 20, null: false, unique: true
      String :email, size: 255, unique: true
      String :password_digest, fixed: true, size: 60
      column :token, :uuid
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:users)
  end
end
