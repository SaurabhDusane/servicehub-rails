class ReviewRequestSchedulerJob < ApplicationJob
  queue_as :low

  def perform
    Booking.where(status: :completed, review_request_sent_at: nil)
           .where("completed_at <= ?", 1.hour.ago)
           .find_each do |booking|
      BookingMailer.review_request(booking.id).deliver_later
      booking.update_columns(review_request_sent_at: Time.current)
    end
  end
end
