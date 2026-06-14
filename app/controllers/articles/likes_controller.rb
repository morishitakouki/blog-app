class Articles::LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article

  # POST /articles/:article_id/like
  def create
    current_user.likes.find_or_create_by(article: @article)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @article }
    end
  end

  # DELETE /articles/:article_id/like
  def destroy
    current_user.likes.where(article: @article).destroy_all
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @article }
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end
end
