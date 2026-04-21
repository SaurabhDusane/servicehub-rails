class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :booking,          null: false, foreign_key: true, index: { unique: true }
      t.references :customer,         null: false, foreign_key: { to_table: :users }
      t.references :provider_profile, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text    :body
      t.boolean :hidden, null: false, default: false
      t.text    :moderation_notes
      t.timestamps
    end

    add_index :reviews, :rating
    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "rating_range"
  end
end
