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
      Article.with_attached_image.order(created_at: :desc, id: :desc)
      .group_by(&:category)
      .transform_values { |items| items.first(3) }
      .sort.to_h # show categories alphabetically

    # Trending Now: hand-picked stories (trending_position 1-3) first,
    # then the newest stories fill any empty slots
    picked = Article.with_attached_image.where.not(trending_position: nil).order(:trending_position).limit(3).to_a
    newest = Article.with_attached_image.where.not(id: picked.map(&:id)).order(created_at: :desc, id: :desc).limit(3 - picked.size)
    @trending_articles = picked + newest
  end

  def index
    # Optional ?category=World filter, used by the category links in the nav bar
    @category = params[:category].presence if params[:category].is_a?(String)

    @articles = Article.includes(:user).with_attached_image.order(created_at: :desc, id: :desc)
    @articles = @articles.where(category: @category) if @category

    # Optional ?q=keyword search from the header's search box (title or content)
    @query = params[:q].to_s.strip.presence if params[:q].is_a?(String)
    if @query
      pattern = "%#{Article.sanitize_sql_like(@query)}%"
      @articles = @articles.where("title LIKE :pattern OR content LIKE :pattern", pattern: pattern)
    end
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
    params.require(:article).permit(:title, :content, :category, :image, :remove_image)
  end

  def require_signup_for_guests
    return if user_signed_in?

    redirect_to new_user_registration_path,
      alert: "Please sign up or log in to read the full article."
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def set_owned_article
    @article = current_user.articles.find(params[:id])
  end
end
