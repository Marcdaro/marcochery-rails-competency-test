require "test_helper"

class ArticlePermissionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @editor = User.create!(
      email: "editor@example.com",
      password: "password",
      role: :editor
      )

      @other_editor = User.create!(
        email: "other_editor@example.com",
        password: "password",
        role: :editor
      )

      @reader = User.create!(
        email: "reader@example.com",
        password: "password"
      )

      @admin = User.create!(
        email: "admin@example.com",
        password: "password",
        role: :admin
      )

      @article = Article.create!(
        title: "Test Article",
        content: "This is a test article.",
        category: "Test",
        user: @editor
      )
  end

  test "guests can view home and index" do
    get root_path
    assert_response :success

    get articles_path
    assert_response :success
  end

  test "guests must sign up to view articles" do
    get article_path(@article)
    assert_redirected_to new_user_registration_path
  end

  test "logged in users can view articles" do
    sign_in @reader
    get article_path(@article)
    assert_response :success
  end

  test "editors can create articles" do
    sign_in @editor

    assert_difference("Article.count", 1) do
      post articles_path, params: {
        article: {
          title: "New Article",
          content: "This is a new article.",
          category: "Test"
        }
      }
    end

    assert_equal @editor.id, Article.last.user_id
  end

  test "editors cannot edit other user articles" do
    sign_in @other_editor

    patch article_path(@article), params: {
      article: { title: "Change not allowed" }
  }
    assert_response :not_found
    assert_equal "Test Article", @article.reload.title
  end

  test "regular users cannot create articles" do
    sign_in @reader

    assert_no_difference("Article.count") do
      post articles_path, params: {
        article: {
          title: "Unauthorized Article",
          content: "Can't create this.",
          category: "N/A"
        }
      }
    end
  end

  test "admins cannot create articles" do
    sign_in @admin

    assert_no_difference("Article.count") do
      post articles_path, params: {
        article: {
          title: "Admin Article",
          content: "Admins can't create articles.",
          category: "N/A"
        }
      }
    end
  end
end
