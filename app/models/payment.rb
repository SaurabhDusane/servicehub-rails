class Payment < ApplicationRecord
  belongs_to :booking

  enum status: {
    pending: 0, processing: 1, succeeded: 2,
    failed: 3, refunded: 4, partially_refunded: 5
  }, _default: :pending

  enum kind: { deposit: 0, full: 1, balance: 2 }, _default: :full, _prefix: true

  monetize :amount_cents, as: :amount
  monetize :refunded_amount_cents, as: :refunded_amount

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :stripe_payment_intent_id, uniqueness: true, allow_nil: true

  scope :successful, -> { where(status: %i[succeeded partially_refunded]) }

  def net_amount_cents
    amount_cents - refunded_amount_cents
  end
end
