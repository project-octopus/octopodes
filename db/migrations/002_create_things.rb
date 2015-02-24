Sequel.migration do
  up do
    create_table(:things) do
      primary_key :id
      column :uuid, :uuid, null: false, unique: true
      String :type, size: 100, null: false, default: 'Thing'
      Text :license
      Text :description
      Text :name
      String :url, size: 2048
      DateTime :created_at
      DateTime :updated_at

      foreign_key :updated_by_id, :users

      index :url
    end
  end

  down do
    drop_table(:things)
  end
end
