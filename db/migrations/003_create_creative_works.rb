Sequel.migration do
  up do
    create_table(:creative_works) do
      foreign_key :id, :things, on_delete: :cascade
      primary_key [:id]
      Text :creator
      Text :date_created
      Text :date_published
      Text :publisher
      String :is_based_on_url, size: 2048
      String :associated_media, size: 2048

      foreign_key :is_part_of_id, :creative_works, on_delete: :cascade
      foreign_key :example_of_work_id, :creative_works
    end
  end

  down do
    drop_table(:creative_works)
  end
end
