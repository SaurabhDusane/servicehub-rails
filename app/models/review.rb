class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :customer, class_name: "User"
  belongs_to :provider_profile

  has_many_attached :photos

  validates :rating, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :booking_id, uniqueness: true
  validate  :booking_must_be_completed
  validate  :customer_matches_booking

  after_save       :sync_provider_rating
  after_destroy    :sync_provider_rating

  scope :visible, -> { where(hidden: false) }
  scope :hidden_reviews, -> { where(hidden: true) }

  private

  def booking_must_be_completed
    return if booking.blank?
    errors.add(:booking, "must be completed before reviewing") unless booking.completed?
  end

  def customer_matches_booking
    return if booking.blank? || customer.blank?
    errors.add(:customer, "must be the customer on the booking") unless booking.customer_id == customer_id
  end

  def sync_provider_rating
    provider_profile.recalculate_rating!
  end
end
