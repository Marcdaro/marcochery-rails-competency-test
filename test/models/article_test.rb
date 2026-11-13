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
end
