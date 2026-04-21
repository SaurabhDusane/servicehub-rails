class NotifyProviderJob < ApplicationJob
  queue_as :default

  def perform(booking_id, kind)
    booking = Booking.find(booking_id)
    provider_user = booking.provider_profile.user
    Notifications::Creator.call(
      user: provider_user,
      kind: kind,
      title: "New booking: #{booking.service.name}",
      body: "#{booking.customer.full_name} booked for #{booking.start_time.strftime('%b %d, %l:%M %p')}",
      url: Rails.application.routes.url_helpers.provider_booking_path(booking),
      metadata: { booking_id: booking_id }
    )
  end
end
