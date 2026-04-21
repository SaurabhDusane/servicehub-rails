class Provider::AvailabilityWindowsController < Provider::BaseController
  before_action :set_window, only: %i[edit update destroy]

  def index
    @windows = current_profile.availability_windows.order(:day_of_week, :start_time)
    @window  = current_profile.availability_windows.build
  end

  def new
    @window = current_profile.availability_windows.build
    authorize @window
  end

  def create
    @window = current_profile.availability_windows.build(window_params)
    authorize @window
    if @window.save
      redirect_to provider_availability_windows_path, notice: "Window added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @window.update(window_params)
      redirect_to provider_availability_windows_path, notice: "Window updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @window.destroy
    redirect_to provider_availability_windows_path, notice: "Window removed."
  end

  private

  def set_window
    @window = current_profile.availability_windows.find(params[:id])
    authorize @window
  end

  def window_params
    params.require(:availability_window).permit(:day_of_week, :start_time, :end_time)
  end
end
