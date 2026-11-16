class Article < ApplicationRecord
  IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE = 5.megabytes

  belongs_to :user

  # Optional photo, shown on the homepage, the article index and the article page.
  # Stored with Active Storage (storage/ on disk).
  has_one_attached :image

  validates :title, :content, :category, presence: true
  validate :image_is_a_reasonable_picture

  private

  def image_is_a_reasonable_picture
    return unless image.attached?

    unless image.blob.content_type.in?(IMAGE_TYPES)
      errors.add(:image, "must be a JPEG, PNG, WebP or GIF")
    end

    if image.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "must be smaller than #{MAX_IMAGE_SIZE / 1.megabyte} MB")
    end
  end
end
