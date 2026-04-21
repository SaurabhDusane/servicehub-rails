class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :provider_profile, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.integer  :status, null: false, default: 0
      t.integer  :payment_status, null: false, default: 0
      t.datetime :start_time, null: false
      t.datetime :end_time,   null: false
      t.string   :timezone, null: false, default: "UTC"
      t.integer  :price_cents, null: false, default: 0
      t.integer  :deposit_cents, null: false, default: 0
      t.string   :currency, null: false, default: "USD"
      t.text     :notes
      t.text     :cancellation_reason
      t.datetime :cancelled_at
      t.references :cancelled_by, foreign_key: { to_table: :users }
      t.datetime :confirmed_at
      t.datetime :completed_at
      t.datetime :reminder_sent_at
      t.datetime :review_request_sent_at
      t.timestamps
    end

    add_index :bookings, :start_time
    add_index :bookings, [:provider_profile_id, :start_time]
    add_index :bookings, [:customer_id, :start_time]
    add_index :bookings, :status
    add_index :bookings, :payment_status

    # Application-side also enforces this, but keep it sane at DB level:
    add_check_constraint :bookings, "end_time > start_time", name: "booking_time_order"

    # Prevent two ACTIVE (pending/confirmed) bookings for the same provider from overlapping.
    # status values: 0=pending, 1=confirmed
    execute <<~SQL
      ALTER TABLE bookings
        ADD CONSTRAINT no_overlapping_bookings
        EXCLUDE USING gist (
          provider_profile_id WITH =,
          tsrange(start_time, end_time) WITH &&
        )
        WHERE (status IN (0, 1));
    SQL
  end
end
