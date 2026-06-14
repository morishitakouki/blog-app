class SettingsController < ApplicationController
  before_action :authenticate_user!

  # GET /settings — プロフィール編集
  def edit
    @user = current_user
  end

  # PATCH /settings
  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path(@user), notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:user).permit(:display_name, :username, :bio)
  end
end
