class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.string  :action, null: false
      t.string  :target_type
      t.bigint  :target_id
      t.jsonb   :payload, null: false, default: {}
      t.inet    :ip_address
      t.timestamps
    end

    add_index :audit_logs, [:target_type, :target_id]
    add_index :audit_logs, :action
  end
end
