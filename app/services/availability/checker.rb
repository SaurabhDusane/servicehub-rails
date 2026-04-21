module Availability
  class Checker
    def initialize(provider_profile)
      @provider = provider_profile
    end

    def available?(start_time, end_time)
      return false if start_time.blank? || end_time.blank? || end_time <= start_time
      return false unless within_weekly_window?(start_time, end_time)
      return false if blocked_by_exception?(start_time, end_time)
      return false if overlaps_active_booking?(start_time, end_time)

      true
    end

    def within_weekly_window?(start_time, end_time)
      tz = @provider.user&.tz || Time.zone
      s_local = start_time.in_time_zone(tz)
      e_local = end_time.in_time_zone(tz)
      return false unless s_local.to_date == e_local.to_date

      dow = s_local.wday
      windows = @provider.availability_windows.for_day(dow)
      return false if windows.empty?

      windows.any? do |w|
        ws = s_local.change(hour: w.start_time.hour, min: w.start_time.min)
        we = s_local.change(hour: w.end_time.hour,   min: w.end_time.min)
        s_local >= ws && e_local <= we
      end
    end

    def blocked_by_exception?(start_time, end_time)
      tz = @provider.user&.tz || Time.zone
      date = start_time.in_time_zone(tz).to_date
      exceptions = @provider.availability_exceptions.on_date(date)
      return false if exceptions.empty?

      exceptions.any? do |ex|
        if ex.closed?
          true
        else
          s_local = start_time.in_time_zone(tz)
          e_local = end_time.in_time_zone(tz)
          ex_start = s_local.change(hour: ex.start_time.hour, min: ex.start_time.min)
          ex_end   = s_local.change(hour: ex.end_time.hour,   min: ex.end_time.min)
          !(s_local >= ex_start && e_local <= ex_end)
        end
      end
    end

    def overlaps_active_booking?(start_time, end_time, except_id: nil)
      scope = @provider.bookings.where(status: Booking.statuses.values_at(:pending, :confirmed))
      scope = scope.where.not(id: except_id) if except_id
      scope.where("start_time < ? AND end_time > ?", end_time, start_time).exists?
    end
  end
end
