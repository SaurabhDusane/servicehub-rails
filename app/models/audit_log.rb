class AuditLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true

  def self.record!(action:, user: nil, target: nil, payload: {}, ip: nil)
    create!(
      action: action,
      user: user,
      target_type: target&.class&.name,
      target_id: target&.id,
      payload: payload,
      ip_address: ip
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("[AuditLog] failed to record: #{e.message}")
  end
end
