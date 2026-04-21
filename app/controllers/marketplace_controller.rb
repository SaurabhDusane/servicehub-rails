class MarketplaceController < ApplicationController
  def index
    scope = ProviderProfile.discoverable.includes(:user, :services)
    scope = scope.search_text(params[:q])     if params[:q].present?
    scope = scope.by_category(params[:category])
    scope = scope.in_location(params[:location])
    scope = scope.rated_at_least(params[:min_rating])
    scope = apply_price_filter(scope, params[:max_price])
    scope = apply_sort(scope, params[:sort])

    @providers = scope.page(params[:page]).per(12)
    @categories = ProviderProfile::CATEGORIES
  end

  def search
    @providers = ProviderProfile.discoverable.search_text(params[:q].to_s).limit(8)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to marketplace_path(q: params[:q]) }
    end
  end

  private

  def apply_price_filter(scope, max_price)
    return scope if max_price.blank?
    max_cents = (max_price.to_f * 100).to_i
    scope.joins(:services).where("services.price_cents <= ?", max_cents).distinct
  end

  def apply_sort(scope, sort)
    case sort
    when "rating"   then scope.order(average_rating: :desc)
    when "reviews"  then scope.order(total_reviews: :desc)
    when "newest"   then scope.order(created_at: :desc)
    else scope.order(average_rating: :desc, total_reviews: :desc)
    end
  end
end
