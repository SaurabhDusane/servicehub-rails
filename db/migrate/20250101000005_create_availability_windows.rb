class CreateAvailabilityWindows < ActiveRecord::Migration[7.1]
  def change
    create_table :availability_windows do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time    :start_time, null: false
      t.time    :end_time,   null: false
      t.timestamps
    end

    add_index :availability_windows, [:provider_profile_id, :day_of_week]
    add_check_constraint :availability_windows, "day_of_week BETWEEN 0 AND 6", name: "day_of_week_range"
  end
end
