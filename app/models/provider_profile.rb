class ProviderProfile < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model

  CATEGORIES = %w[
    haircuts tutoring cleaning photography car_repair
    personal_training consulting massage pet_care home_services
  ].freeze

  RESPONSE_TIMES = %w[within_1h within_4h within_24h within_48h].freeze

  enum status: { pending_review: 0, active: 1, suspended: 2 }, _default: :pending_review, _prefix: true

  friendly_id :business_name, use: %i[slugged history]

  belongs_to :user

  has_many :services, dependent: :destroy
  has_many :availability_windows, dependent: :destroy
  has_many :availability_exceptions, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_error
  has_many :reviews, -> { where(hidden: false) }, dependent: :destroy
  has_many :all_reviews, class_name: "Review", dependent: :destroy
  has_many :favorites, dependent: :destroy

  has_one_attached :cover_image
  has_many_attached :gallery

  validates :business_name, presence: true, length: { maximum: 120 }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :response_time, inclusion: { in: RESPONSE_TIMES }, allow_nil: true
  validates :service_radius_km, numericality: { greater_than: 0, less_than_or_equal_to: 500 }, allow_nil: true
  validates :cancellation_cutoff_hours,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 168 }

  scope :discoverable,        -> { where(status: :active, onboarding_completed: true) }
  scope :by_category,         ->(cat) { where(category: cat) if cat.present? }
  scope :rated_at_least,      ->(r)   { where("average_rating >= ?", r.to_f) if r.present? }
  scope :in_location,         ->(q)   { where("location ILIKE ?", "%#{sanitize_sql_like(q)}%") if q.present? }

  pg_search_scope :search_text,
                  against: { business_name: "A", category: "B", location: "B", bio: "C" },
                  using: { tsearch: { prefix: true, dictionary: "english" } }

  def avatar_url
    return user.avatar_url if user&.avatar&.attached?
    nil
  end

  def starting_price_cents
    services.active.minimum(:price_cents) || 0
  end

  def starting_price
    Money.new(starting_price_cents, services.first&.currency || "USD")
  end

  def recalculate_rating!
    visible = reviews.reload
    count = visible.size
    avg = count.zero? ? 0.0 : visible.average(:rating).to_f.round(2)
    update_columns(average_rating: avg, total_reviews: count)
  end

  def should_generate_new_friendly_id?
    business_name_changed? || super
  end
end
