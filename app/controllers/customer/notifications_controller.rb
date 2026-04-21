class Customer::NotificationsController < Customer::BaseController
  def index
    @notifications = policy_scope(Notification).recent.page(params[:page]).per(25)
  end

  def read
    notification = current_user.notifications.find(params[:id])
    authorize notification
    notification.mark_read!
    redirect_back(fallback_location: customer_notifications_path)
  end

  def read_all
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to customer_notifications_path, notice: "All notifications marked as read."
  end
end
