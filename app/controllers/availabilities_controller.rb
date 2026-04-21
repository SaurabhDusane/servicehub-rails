class AvailabilitiesController < ApplicationController
  def show
    @provider = ProviderProfile.friendly.find(params[:provider_id])
    @service  = @provider.services.active.find(params[:service_id]) if params[:service_id]
    return render json: { slots: [] } unless @service
    @date  = (Date.parse(params[:date].to_s) rescue Time.zone.today)
    @slots = Availability::SlotGenerator.new(@provider, @service, date: @date).call

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { slots: @slots.map { |s| { start: s.start_time.iso8601, end: s.end_time.iso8601 } } } }
    end
  end
end
