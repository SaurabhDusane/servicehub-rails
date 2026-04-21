class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.string  :name, null: false
      t.text    :description
      t.string  :category, null: false
      t.integer :duration_minutes, null: false, default: 60
      t.integer :price_cents, null: false, default: 0
      t.integer :deposit_cents, null: false, default: 0
      t.string  :currency, null: false, default: "USD"
      t.boolean :instant_booking, null: false, default: false
      t.boolean :requires_approval, null: false, default: true
      t.boolean :active, null: false, default: true
      t.integer :buffer_minutes, null: false, default: 0
      t.timestamps
    end

    add_index :services, :category
    add_index :services, :active
    add_index :services, [:provider_profile_id, :active]
  end
end
