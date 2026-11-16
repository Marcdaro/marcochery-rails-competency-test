class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Lets every view (including the layout's nav bar) call nav_categories
  helper_method :nav_categories

  private

  # Every category that has at least one article, alphabetically
  def nav_categories
    @nav_categories ||= Article.distinct.order(:category).pluck(:category)
  end
end
