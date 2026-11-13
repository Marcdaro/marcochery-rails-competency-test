require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user needs an email" do
    user = User.new(
      email: "",
      password: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "user needs a password" do
    user = User.new(
      email: "test@marco.com",
      password: ""
    )
    assert_not user.valid?
  end

  test "user has a default role" do
    user = User.create!(
      email: "test@marco.com",
      password: "password123"
    )
    assert user.has_role?(:user)
    assert_not user.has_role?(:editor)
    assert_not user.has_role?(:admin)
  end

  test "editor role is recognized" do
    editor = User.create!(
      email: "test@marco.com",
      password: "password123",
      role: :editor
    )

    assert editor.has_role?(:editor)
    assert_not editor.has_role?(:admin)
  end

  test "admin role is recognized" do
    admin = User.create!(
      email: "test@marco.com",
      password: "password123",
      role: :admin
    )

    assert admin.has_role?(:admin)
    assert_not admin.has_role?(:editor)
  end

  test "user can have many articles" do
    user = User.create!(
      email: "test@marco.com",
      password: "password123"
    )

    2.times do |i|
      user.articles.create!(
        title: "Test Article #{i}",
        content: "This is a contentful article",
        category: "Test"
      )
    end
    assert_equal 2, user.articles.count
  end
end
