class BookingReminderSchedulerJob < ApplicationJob
  queue_as :low

  def perform
    Booking.where(status: :confirmed, reminder_sent_at: nil)
           .where(start_time: Time.current..24.hours.from_now)
           .find_each do |booking|
      BookingMailer.reminder(booking.id).deliver_later
      booking.update_columns(reminder_sent_at: Time.current)
    end
  end
end
