Sequel.migration do
  string_size = 2048

  up do
    create_table(:things) do
      primary_key :id
      String :type, :null=>false, :default=>"Thing"
      String :license, :size=>string_size
      String :name, :size=>string_size
      String :url, :size=>string_size
    end

    create_table(:creative_works) do
      primary_key :id
      foreign_key :thing_id, :things
      foreign_key :about, :things
      String :creator, :size=>string_size
      Date :date_created
      String :publisher, :size=>string_size
    end

    create_table(:creative_work_has_part) do
      primary_key :id
      foreign_key :creative_work_id, :creative_works
      foreign_key :has_part_id, :creative_works
    end

    create_table(:media_objects) do
      primary_key :id
      foreign_key :creative_work_id, :creative_works
      String :content_url, :size=>string_size
    end
  end

  down do
    drop_table(:media_objects)
    drop_table(:creative_work_has_part)
    drop_table(:creative_works)
    drop_table(:things)
  end
end
