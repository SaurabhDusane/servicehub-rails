class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string  :target_type, null: false
      t.bigint  :target_id,   null: false
      t.string  :reason, null: false
      t.text    :notes
      t.integer :status, null: false, default: 0
      t.references :resolved_by, foreign_key: { to_table: :users }
      t.datetime :resolved_at
      t.text     :resolution_notes
      t.timestamps
    end

    add_index :reports, [:target_type, :target_id]
    add_index :reports, :status
  end
end
