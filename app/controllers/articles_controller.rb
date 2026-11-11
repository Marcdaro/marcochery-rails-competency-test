class ArticlesController < ApplicationController
  before_action :authenticate_user!,
    only: [ :new, :create, :edit, :update, :destroy ]

  # Access control for the different user roles
  # Let guests reach the home, index and show actions, but require them to sign up to view articles

  access all: [ :home, :index, :show ],
        editor: [ :new, :create, :edit, :update, :destroy ]

  before_action :require_signup_for_guests, only: :show
  before_action :set_article, only: :show
  before_action :set_owned_article,
    only: [ :edit, :update, :destroy ]

  def home
    @articles_by_category =
      Article.order(created_at: :desc, id: :desc)
      .group_by(&:category)
      .transform_values { |items| items.first(3) }
  end

  def index
    @articles = Article.order(created_at: :desc, id: :desc)
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.new(article_params)

    if @article.save
      redirect_to @article, notice: "Article was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy!
    redirect_to articles_path, notice: "Article was successfully deleted!"
  end

  private

  def article_params
    params.require(:article).permit(:title, :content, :category)
  end

  def require_signup_for_guests
    return if user_signed_in?

    redirect_to new_user_registration_path,
      alert: "Come on big bro, you gotta sign in to view this article!!"
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def set_owned_article
    @article = current_user.articles.find(params[:id])
  end
end
