class BookingMailer < ApplicationMailer
  def confirmation(booking_id)
    @booking = Booking.find(booking_id)
    @customer = @booking.customer
    mail to: @customer.email, subject: "Your booking with #{@booking.provider_profile.business_name} is confirmed"
  end

  def cancelled(booking_id)
    @booking = Booking.find(booking_id)
    mail to: @booking.customer.email, subject: "Your booking was cancelled"
  end

  def reminder(booking_id)
    @booking = Booking.find(booking_id)
    mail to: @booking.customer.email, subject: "Reminder: upcoming appointment with #{@booking.provider_profile.business_name}"
  end

  def review_request(booking_id)
    @booking = Booking.find(booking_id)
    mail to: @booking.customer.email, subject: "How was your experience with #{@booking.provider_profile.business_name}?"
  end

  def payment_confirmation(booking_id, payment_id)
    @booking = Booking.find(booking_id)
    @payment = Payment.find(payment_id)
    mail to: @booking.customer.email, subject: "Payment received"
  end
end
