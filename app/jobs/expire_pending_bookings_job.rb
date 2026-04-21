class ExpirePendingBookingsJob < ApplicationJob
  queue_as :low

  EXPIRY = 48.hours

  def perform
    Booking.where(status: :pending)
           .where("created_at < ?", EXPIRY.ago)
           .find_each do |booking|
      booking.update!(status: :rejected, cancellation_reason: "Auto-expired: no provider response")
      AuditLog.record!(action: "booking.auto_rejected", target: booking, payload: { reason: "expired" })
      BookingMailer.cancelled(booking.id).deliver_later
    end
  end
end
