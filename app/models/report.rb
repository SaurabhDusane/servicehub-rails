class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :resolved_by, class_name: "User", optional: true

  REASONS = %w[spam abuse inappropriate fraud other].freeze
  TARGETS = %w[ProviderProfile Review User Booking].freeze

  enum status: { open: 0, investigating: 1, resolved: 2, dismissed: 3 }, _default: :open

  validates :reason, inclusion: { in: REASONS }
  validates :target_type, inclusion: { in: TARGETS }
  validates :target_id, presence: true

  def target
    target_type.constantize.find_by(id: target_id)
  end
end
