class CreateVoltronTemp < ActiveRecord::Migration[4.2]
  def change
    create_table :voltron_temps do |t|
      t.integer :hash_id, limit: 8
      t.string :file
      t.string :column
      t.string :name
      t.boolean :multiple

      t.timestamps null: false
    end

    add_index :voltron_temps, :hash_id, unique: true
  end
end
