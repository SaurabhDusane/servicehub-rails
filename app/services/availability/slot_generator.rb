module Availability
  # Generates bookable slots for a provider's service on a given date (in the provider's TZ).
  class SlotGenerator
    SlotResult = Struct.new(:start_time, :end_time, keyword_init: true) do
      def to_param
        start_time.iso8601
      end
    end

    def initialize(provider_profile, service, date:, step_minutes: 15)
      @provider = provider_profile
      @service  = service
      @date     = date.is_a?(Date) ? date : Date.parse(date.to_s)
      @step     = step_minutes
      @checker  = Checker.new(provider_profile)
    end

    def call
      tz = @provider.user&.tz || Time.zone
      dow = @date.wday
      windows = @provider.availability_windows.for_day(dow)
      return [] if windows.empty?

      duration = @service.duration_minutes.minutes
      buffer   = @service.buffer_minutes.minutes

      windows.flat_map do |w|
        window_start = tz.local(@date.year, @date.month, @date.day, w.start_time.hour, w.start_time.min)
        window_end   = tz.local(@date.year, @date.month, @date.day, w.end_time.hour,   w.end_time.min)

        slots = []
        cursor = window_start
        cursor = Time.current.in_time_zone(tz).ceil(@step.minutes) if @date == Time.current.in_time_zone(tz).to_date && cursor < Time.current
        while cursor + duration <= window_end
          slot_end = cursor + duration
          slots << SlotResult.new(start_time: cursor, end_time: slot_end) if @checker.available?(cursor, slot_end)
          cursor += @step.minutes + buffer
        end
        slots
      end
    end
  end
end
