class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  enum role: { customer: 0, provider: 1, admin: 2 }, _default: :customer

  has_one_attached :avatar

  has_one  :provider_profile, dependent: :destroy
  has_many :bookings_as_customer, class_name: "Booking", foreign_key: :customer_id, dependent: :nullify, inverse_of: :customer
  has_many :reviews_written, class_name: "Review", foreign_key: :customer_id, dependent: :nullify, inverse_of: :customer
  has_many :favorites, dependent: :destroy
  has_many :favorite_providers, through: :favorites, source: :provider_profile
  has_many :notifications, dependent: :destroy
  has_many :reports_filed, class_name: "Report", foreign_key: :reporter_id, dependent: :nullify, inverse_of: :reporter
  has_many :audit_logs, dependent: :nullify

  validates :timezone, presence: true, inclusion: {
    in: ->(_) { ActiveSupport::TimeZone::MAPPING.keys + ActiveSupport::TimeZone::MAPPING.values }
  }
  validates :first_name, :last_name, presence: true
  validates :phone_number, length: { maximum: 32 }, allow_blank: true

  before_validation :normalize_email

  scope :active, -> { where(active: true) }

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || email
  end

  def display_name
    full_name
  end

  def tz
    ActiveSupport::TimeZone[timezone] || Time.zone
  end

  def avatar_url(variant: :thumb)
    return nil unless avatar.attached?
    Rails.application.routes.url_helpers.rails_representation_url(
      avatar.variant(resize_to_fill: [200, 200]), only_path: true
    )
  rescue StandardError
    nil
  end

  def provider?
    super && provider_profile.present?
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end
end
