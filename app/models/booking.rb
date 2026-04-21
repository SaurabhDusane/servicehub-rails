class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :provider_profile
  belongs_to :service
  belongs_to :cancelled_by, class_name: "User", optional: true

  has_many :payments, dependent: :destroy
  has_one  :review, dependent: :destroy

  enum status: {
    pending: 0, confirmed: 1, completed: 2,
    cancelled: 3, rejected: 4, no_show: 5
  }, _default: :pending

  enum payment_status: {
    unpaid: 0, deposit_paid: 1, paid: 2, refunded: 3, partially_refunded: 4, failed: 5
  }, _default: :unpaid, _prefix: true

  monetize :price_cents,   as: :price
  monetize :deposit_cents, as: :deposit

  validates :start_time, :end_time, :timezone, presence: true
  validate  :end_after_start
  validate  :within_provider_availability, on: :create
  validate  :not_in_the_past, on: :create

  scope :upcoming,  -> { where("start_time >= ?", Time.current) }
  scope :past,      -> { where("end_time < ?",   Time.current) }
  scope :active,    -> { where(status: %i[pending confirmed]) }

  ACTIVE_STATUSES = %w[pending confirmed].freeze
  CANCELLABLE_BY_CUSTOMER = %w[pending confirmed].freeze

  def duration_minutes
    ((end_time - start_time) / 60).to_i
  end

  def tz
    ActiveSupport::TimeZone[timezone] || Time.zone
  end

  def cancellable_by_customer?(now = Time.current)
    return false unless CANCELLABLE_BY_CUSTOMER.include?(status)
    cutoff = provider_profile.cancellation_cutoff_hours.to_i.hours
    (start_time - now) > cutoff
  end

  def reviewable?
    completed? && review.nil?
  end

  def total_paid_cents
    payments.where(status: %i[succeeded]).sum(:amount_cents) -
      payments.sum(:refunded_amount_cents)
  end

  def balance_due_cents
    [price_cents - total_paid_cents, 0].max
  end

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def not_in_the_past
    return if start_time.blank?
    errors.add(:start_time, "must be in the future") if start_time < Time.current
  end

  def within_provider_availability
    return if provider_profile.blank? || start_time.blank? || end_time.blank?
    unless Availability::Checker.new(provider_profile).available?(start_time, end_time)
      errors.add(:start_time, :outside_availability)
    end
  end
end
