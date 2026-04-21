class CreateProviderProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :provider_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :business_name, null: false
      t.string  :slug, null: false
      t.text    :bio
      t.string  :category, null: false
      t.string  :location
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :service_radius_km, default: 25
      t.string  :response_time, default: "within_24h"
      t.text    :cancellation_policy
      t.integer :cancellation_cutoff_hours, default: 24
      t.decimal :average_rating, precision: 3, scale: 2, default: 0.0, null: false
      t.integer :total_reviews, default: 0, null: false
      t.integer :status, null: false, default: 0
      t.boolean :onboarding_completed, null: false, default: false
      t.string  :website
      t.string  :instagram
      t.timestamps
    end

    add_index :provider_profiles, :slug, unique: true
    add_index :provider_profiles, :category
    add_index :provider_profiles, :average_rating
    add_index :provider_profiles, :status
  end
end
