class Service < ApplicationRecord
  belongs_to :provider_profile
  has_many :bookings, dependent: :restrict_with_error
  has_many_attached :images

  monetize :price_cents,   as: :price
  monetize :deposit_cents, as: :deposit

  validates :name, presence: true, length: { maximum: 120 }
  validates :category, presence: true
  validates :duration_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 24 * 60 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :deposit_cents, numericality: { greater_than_or_equal_to: 0 }
  validate  :deposit_not_greater_than_price

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def duration
    duration_minutes.minutes
  end

  def requires_deposit?
    deposit_cents.positive? && deposit_cents < price_cents
  end

  def amount_due_now_cents(full: false)
    return price_cents if full || !requires_deposit?
    deposit_cents
  end

  private

  def deposit_not_greater_than_price
    return if deposit_cents.to_i <= price_cents.to_i
    errors.add(:deposit_cents, "cannot exceed price")
  end
end
