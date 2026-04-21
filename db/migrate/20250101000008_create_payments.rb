class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.string  :stripe_payment_intent_id
      t.string  :stripe_charge_id
      t.integer :amount_cents, null: false, default: 0
      t.integer :refunded_amount_cents, null: false, default: 0
      t.string  :currency, null: false, default: "USD"
      t.integer :status, null: false, default: 0
      t.integer :kind, null: false, default: 0 # deposit / full / balance
      t.string  :receipt_url
      t.jsonb   :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :payments, :stripe_payment_intent_id, unique: true
    add_index :payments, :status
  end
end
