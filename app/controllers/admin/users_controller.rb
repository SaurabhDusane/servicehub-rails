class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.order(created_at: :desc).page(params[:page]).per(25)
  end

  def show; end

  def update
    authorize @user
    if @user.update(user_params)
      AuditLog.record!(action: "user.updated", user: current_user, target: @user, payload: user_params.to_h)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.update!(active: false)
    AuditLog.record!(action: "user.deactivated", user: current_user, target: @user)
    redirect_to admin_users_path, notice: "User deactivated."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role, :active, :first_name, :last_name)
  end
end
