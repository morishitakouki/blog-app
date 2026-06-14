class ArticlesController < ApplicationController
  # 一覧・詳細は誰でも閲覧可、それ以外はログイン必須
  before_action :authenticate_user!, except: %i[ index show ]
  before_action :set_article, only: %i[ show edit update destroy ]
  # 編集・更新・削除は記事の所有者のみ
  before_action :authorize_owner!, only: %i[ edit update destroy ]

  # GET /articles or /articles.json — みんなのタイムライン（誰でも閲覧可）
  def index
    @articles = Article.includes(:user, :likes).newest_first
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    @article = current_user.articles.build(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "Article was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # 記事の所有者でなければ一覧へリダイレクト
    def authorize_owner!
      unless @article.user == current_user
        redirect_to articles_path, alert: "他のユーザーの記事は操作できません。"
      end
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
