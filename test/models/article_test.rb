require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "test-author@marco.com",
      password: "password123"
    )
  end

  test "valid article" do
    article = Article.new(
      title: "Test Article",
      content: "This is a test article.",
      category: "Test",
      user: @user
    )
    assert article.valid?
  end

  test "article has a title" do
    article = Article.new(
      title: "",
      content: "This is a test article.",
      category: "Technology",
      user: @user
    )
    assert_not article.valid?
    assert_includes article.errors[:title], "can't be blank"
  end

  test "article needs content" do
    article = Article.new(
      title: "Test Article",
      content: "",
      category: "Technology",
      user: @user
    )
    assert_not article.valid?
  end

  test "article needs a category" do
    article = Article.new(
      title: "Test Article",
      content: "This is a test article.",
      category: "",
      user: @user
    )
    assert_not article.valid?
  end

  test "article belongs to a user" do
    article = @user.articles.create!(
      title: "Test Article",
      content: "This is a test article.",
      category: "Technology"
    )
    assert_equal @user, article.user
    assert_equal @user.id, article.user_id
  end

  test "article can have an image" do
    article = @user.articles.new(title: "Pictured", content: "Body", category: "Technology")
    article.image.attach(io: file_fixture("sample.jpg").open, filename: "sample.jpg", content_type: "image/jpeg")

    assert article.valid?
    article.save!
    assert article.reload.image.attached?
  end

  test "article image must be a picture" do
    article = @user.articles.new(title: "Not pictured", content: "Body", category: "Technology")
    article.image.attach(io: file_fixture("not_an_image.txt").open, filename: "notes.txt", content_type: "text/plain")

    assert_not article.valid?
    assert_includes article.errors[:image], "must be a JPEG, PNG, WebP or GIF"
  end

  test "article image must be under the size limit" do
    article = @user.articles.new(title: "Huge", content: "Body", category: "Technology")
    article.image.attach(io: StringIO.new("x" * (Article::MAX_IMAGE_SIZE + 1)), filename: "huge.jpg", content_type: "image/jpeg")

    assert_not article.valid?
    assert_includes article.errors[:image], "must be smaller than 5 MB"
  end
end
