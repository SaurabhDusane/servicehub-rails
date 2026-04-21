class Provider::AvailabilityExceptionsController < Provider::BaseController
  before_action :set_exception, only: %i[edit update destroy]

  def index
    @exceptions = current_profile.availability_exceptions.order(date: :asc)
    @exception = current_profile.availability_exceptions.build
  end

  def new
    @exception = current_profile.availability_exceptions.build
    authorize @exception
  end

  def create
    @exception = current_profile.availability_exceptions.build(exception_params)
    authorize @exception
    if @exception.save
      redirect_to provider_availability_exceptions_path, notice: "Exception added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @exception.update(exception_params)
      redirect_to provider_availability_exceptions_path, notice: "Exception updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exception.destroy
    redirect_to provider_availability_exceptions_path, notice: "Exception removed."
  end

  private

  def set_exception
    @exception = current_profile.availability_exceptions.find(params[:id])
    authorize @exception
  end

  def exception_params
    params.require(:availability_exception).permit(:date, :start_time, :end_time, :exception_type, :reason)
  end
end
