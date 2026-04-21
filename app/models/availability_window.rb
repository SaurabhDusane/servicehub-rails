class AvailabilityWindow < ApplicationRecord
  belongs_to :provider_profile

  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
  validate  :end_after_start
  validate  :no_overlap_with_other_windows_same_day

  scope :for_day, ->(dow) { where(day_of_week: dow) }

  def day_name
    DAY_NAMES[day_of_week]
  end

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlap_with_other_windows_same_day
    return unless provider_profile_id && day_of_week && start_time && end_time
    siblings = AvailabilityWindow.where(provider_profile_id: provider_profile_id, day_of_week: day_of_week).where.not(id: id)
    siblings.each do |w|
      if start_time < w.end_time && end_time > w.start_time
        errors.add(:base, "overlaps with another availability window on #{day_name}")
        break
      end
    end
  end
end
