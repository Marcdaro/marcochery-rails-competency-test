require "test_helper"

class ArticlePermissionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @editor = User.create!(
      email: "editor@marco.com",
      password: "password123",
      role: :editor
    )

    @other_editor = User.create!(
      email: "other_editor@marco.com",
      password: "password321",
      role: :editor
    )

    @reader = User.create!(
      email: "reader@marco.com",
      password: "password0924"
    )

    @admin = User.create!(
      email: "admin@marco.com",
      password: "password1222",
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

  test "editors can edit their own articles" do
    sign_in @editor

    patch article_path(@article), params: { article: { title: "Updated Title" } }

    assert_redirected_to article_path(@article)
    assert_equal "Updated Title", @article.reload.title
  end

  test "editors can delete their own articles" do
    sign_in @editor

    assert_difference("Article.count", -1) do
      delete article_path(@article)
    end
    assert_redirected_to articles_path
  end

  test "editors cannot delete other user articles" do
    sign_in @other_editor

    assert_no_difference("Article.count") do
      delete article_path(@article)
    end
    assert_response :not_found
  end

  test "invalid articles are not saved and the form is shown again" do
    sign_in @editor

    assert_no_difference("Article.count") do
      post articles_path, params: { article: { title: "", content: "", category: "" } }
    end
    assert_response :unprocessable_entity
    assert_select "li", text: "Title can't be blank"
  end

  test "guests are sent to log in when trying to create an article" do
    get new_article_path
    assert_redirected_to new_user_session_path
  end

  test "regular users cannot open the new article form" do
    sign_in @reader
    get new_article_path
    assert_response :redirect
    assert_not_equal new_article_path, URI(response.location).path
  end

  test "homepage shows at most three articles per category" do
    4.times do |i|
      Article.create!(title: "Sports #{i}", content: "Body", category: "Sports", user: @editor)
    end

    get root_path

    assert_select "section[data-category=Sports] h3 a", text: /\ASports \d\z/, count: 3
    assert_select "section[data-category=Test] h3 a", text: "Test Article"
  end

  test "homepage trending section shows the three newest stories" do
    4.times do |i|
      Article.create!(title: "Breaking #{i}", content: "Body", category: "World", user: @editor)
    end

    get root_path

    assert_select "section[aria-labelledby=trending-heading] h3 a", count: 3
    assert_select "section[aria-labelledby=trending-heading] h3 a", text: "Breaking 3"
    assert_select "section[aria-labelledby=trending-heading] h3 a", text: "Breaking 0", count: 0
  end

  test "hand-picked trending stories come first, in order" do
    Article.create!(title: "Newest Story", content: "Body", category: "World", user: @editor)
    Article.create!(title: "Second Pick", content: "Body", category: "World", user: @editor, trending_position: 2)
    Article.create!(title: "First Pick", content: "Body", category: "Sports", user: @editor, trending_position: 1)

    get root_path

    trending = css_select("section[aria-labelledby=trending-heading] h3 a").map { |link| link.text.strip }
    assert_equal [ "First Pick", "Second Pick", "Newest Story" ], trending
  end

  test "editors can upload an image with a new article" do
    sign_in @editor

    post articles_path, params: {
      article: {
        title: "Pictured Article", content: "Body", category: "Test",
        image: fixture_file_upload("sample.jpg", "image/jpeg")
      }
    }

    assert Article.find_by(title: "Pictured Article").image.attached?
  end

  test "editors can replace and remove an article image" do
    sign_in @editor
    @article.image.attach(io: file_fixture("sample.jpg").open, filename: "old.jpg", content_type: "image/jpeg")

    get edit_article_path(@article)
    assert_select "img[alt=?]", "Current image"
    assert_select "input[type=checkbox][name=?]", "article[remove_image]"

    patch article_path(@article), params: { article: { image: fixture_file_upload("sample.jpg", "image/jpeg") } }
    assert @article.reload.image.attached?

    patch article_path(@article), params: { article: { remove_image: "1" } }
    assert_not @article.reload.image.attached?
  end

  test "non-image uploads are rejected" do
    sign_in @editor

    assert_no_difference("Article.count") do
      post articles_path, params: {
        article: {
          title: "Bad Upload", content: "Body", category: "Test",
          image: fixture_file_upload("not_an_image.txt", "text/plain")
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "li", text: "Image must be a JPEG, PNG, WebP or GIF"
  end

  test "header has a light/dark theme switch" do
    get root_path
    assert_select "header button[data-controller=theme][data-action=?]", "theme#toggle"
  end

  test "article index can be searched by title or content" do
    Article.create!(title: "Match Report", content: "A thrilling final", category: "Sports", user: @editor)

    get articles_path(q: "thrilling")

    assert_response :success
    assert_select "h2 a", text: "Match Report"
    assert_select "h2 a", text: "Test Article", count: 0
  end

  test "nav bar links to every category" do
    Article.create!(title: "Match Report", content: "Body", category: "Sports", user: @editor)

    get root_path

    assert_select "nav[aria-label=Sections] a[href=?]", articles_path(category: "Sports"), text: "Sports"
    assert_select "nav[aria-label=Sections] a[href=?]", articles_path(category: "Test"), text: "Test"
  end

  test "article index can be filtered by category" do
    Article.create!(title: "Match Report", content: "Body", category: "Sports", user: @editor)

    get articles_path(category: "Sports")

    assert_response :success
    assert_select "h1", text: "Sports"
    assert_select "h2 a", text: "Match Report"
    assert_select "h2 a", text: "Test Article", count: 0
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

  test "admins cannot edit articles" do
    sign_in @admin

    get edit_article_path(@article)
    assert_response :redirect

    patch article_path(@article), params: { article: { title: "Admin Edit" } }
    assert_equal "Test Article", @article.reload.title
  end

  test "admins cannot delete articles" do
    sign_in @admin

    assert_no_difference("Article.count") do
      delete article_path(@article)
    end
  end
end
