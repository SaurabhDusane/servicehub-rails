class Admin::AuditLogsController < Admin::BaseController
  def index
    @logs = AuditLog.includes(:user).order(created_at: :desc).page(params[:page]).per(50)
  end
end
