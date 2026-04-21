class CreateAvailabilityExceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :availability_exceptions do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.integer :exception_type, null: false, default: 0
      t.string  :reason
      t.timestamps
    end

    add_index :availability_exceptions, [:provider_profile_id, :date]
  end
end
