class UsersController < ApplicationController
  before_action :authenticate_user!, only: :mypage

  # GET /@:username  — 誰でも閲覧できる公開プロフィール
  def show
    @user = User.find_by!(username: params[:username])
    @articles = @user.articles.newest_first
  end

  # GET /mypage  — 自分のプロフィールへ
  def mypage
    @user = current_user
    @articles = @user.articles.newest_first
    render :show
  end
end
