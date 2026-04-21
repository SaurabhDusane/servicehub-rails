class Admin::ReviewsController < Admin::BaseController
  def index
    @reviews = Review.includes(:customer, :provider_profile).order(created_at: :desc).page(params[:page]).per(25)
  end

  def update
    review = Review.find(params[:id])
    authorize review
    review.update!(hidden: ActiveModel::Type::Boolean.new.cast(params[:hidden]), moderation_notes: params[:moderation_notes])
    AuditLog.record!(action: "review.moderated", user: current_user, target: review, payload: { hidden: review.hidden })
    redirect_to admin_reviews_path, notice: "Review updated."
  end

  def destroy
    review = Review.find(params[:id])
    authorize review
    review.destroy
    AuditLog.record!(action: "review.deleted", user: current_user, target: review)
    redirect_to admin_reviews_path, notice: "Review deleted."
  end
end
