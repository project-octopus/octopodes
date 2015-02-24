Sequel.migration do
  up do
    create_table(:web_pages) do
      foreign_key :id, :things, on_delete: :cascade
      primary_key [:id]
    end
  end

  down do
    drop_table(:web_pages)
  end
end
