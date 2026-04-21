class AvailabilityException < ApplicationRecord
  belongs_to :provider_profile

  enum exception_type: { closed: 0, custom_hours: 1 }, _default: :closed

  validates :date, presence: true
  validate  :times_consistent

  scope :on_date, ->(date) { where(date: date) }

  private

  def times_consistent
    if custom_hours?
      errors.add(:start_time, "is required for custom hours") if start_time.blank?
      errors.add(:end_time,   "is required for custom hours") if end_time.blank?
      if start_time.present? && end_time.present? && end_time <= start_time
        errors.add(:end_time, "must be after start time")
      end
    end
  end
end
