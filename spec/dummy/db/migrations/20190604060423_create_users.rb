Hanami::Model.migration do
  up do
    create_table :users do
      primary_key :id, null: false

      column :email,  String, null: false
      column :password_hash, String, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end

  down do
    drop_table :users
  end
end
