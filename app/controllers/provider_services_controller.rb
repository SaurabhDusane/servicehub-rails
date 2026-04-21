class ProviderServicesController < ApplicationController
  def show
    @provider = ProviderProfile.friendly.find(params[:provider_id])
    @service  = @provider.services.find(params[:id])
    authorize @service
    @date = parse_date(params[:date]) || Time.zone.today
    @slots = Availability::SlotGenerator.new(@provider, @service, date: @date).call
  end

  private

  def parse_date(str)
    Date.parse(str.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
