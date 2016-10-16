class CreateVoltronUploads < ActiveRecord::Migration
  def change
    create_table :voltron_uploads do |t|
      t.string :uuid
      t.integer :resource_id
      t.string :resource_type
      t.string :column
      t.string :file

      t.timestamps
    end

    add_index :voltron_uploads, :uuid, unique: true
  end
end
