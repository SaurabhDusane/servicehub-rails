class Admin::ReportsController < Admin::BaseController
  before_action :set_report, only: %i[show update]

  def index
    @reports = Report.includes(:reporter).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show; end

  def update
    authorize @report
    @report.update!(status: params[:status], resolved_by: current_user, resolved_at: Time.current, resolution_notes: params[:resolution_notes])
    AuditLog.record!(action: "report.updated", user: current_user, target: @report, payload: { status: @report.status })
    redirect_to admin_reports_path, notice: "Report updated."
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end
end
