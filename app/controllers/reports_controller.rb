class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @report = Report.new(target_type: params[:target_type], target_id: params[:target_id])
    authorize @report
  end

  def create
    @report = current_user.reports_filed.build(report_params)
    authorize @report
    if @report.save
      AuditLog.record!(action: "report.filed", user: current_user, target: @report, payload: { reason: @report.reason })
      redirect_to root_path, notice: "Report submitted. Thank you."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:report).permit(:target_type, :target_id, :reason, :notes)
  end
end
