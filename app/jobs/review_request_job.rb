class ReviewRequestJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    return unless booking.completed? && booking.review_request_sent_at.nil?
    BookingMailer.review_request(booking_id).deliver_later
    booking.update_columns(review_request_sent_at: Time.current)
  end
end
