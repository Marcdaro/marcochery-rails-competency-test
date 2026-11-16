require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "admin@marco.com", password: "password1222", role: :admin)
    @editor = User.create!(email: "editor@marco.com", password: "password123", role: :editor)
    @reader = User.create!(email: "reader@marco.com", password: "password0924")
  end

  # --- Admins can manage users ---

  test "admins can see the user list" do
    sign_in @admin
    get admin_users_path

    assert_response :success
    assert_select "td", text: /editor@marco.com/
    assert_select "td", text: /reader@marco.com/
  end

  test "admins see a Manage Users link in the header" do
    sign_in @admin
    get root_path
    assert_select "header a[href=?]", admin_users_path, text: "Manage Users"
  end

  test "admins can open the new user and edit user forms" do
    sign_in @admin

    get new_admin_user_path
    assert_response :success
    assert_select "select[name=?]", "user[role]"

    get edit_admin_user_path(@reader)
    assert_response :success
  end

  test "admins can create a user and set their role" do
    sign_in @admin

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          email: "new.editor@marco.com",
          password: "password456",
          password_confirmation: "password456",
          role: "editor"
        }
      }
    end

    assert_redirected_to admin_users_path
    assert User.find_by(email: "new.editor@marco.com").has_role?(:editor)
  end

  test "invalid users are not created and the form is shown again" do
    sign_in @admin

    assert_no_difference("User.count") do
      post admin_users_path, params: { user: { email: "", password: "short", role: "editor" } }
    end
    assert_response :unprocessable_entity
    assert_select "li", text: "Email can't be blank"
  end

  test "admins can change a user's role" do
    sign_in @admin

    patch admin_user_path(@reader), params: { user: { role: "editor" } }

    assert_redirected_to admin_users_path
    assert @reader.reload.has_role?(:editor)
  end

  test "admins can edit a user's email" do
    sign_in @admin

    patch admin_user_path(@reader), params: { user: { email: "renamed@marco.com" } }

    assert_redirected_to admin_users_path
    assert_equal "renamed@marco.com", @reader.reload.email
  end

  test "leaving the password blank keeps the current password" do
    sign_in @admin

    patch admin_user_path(@reader), params: {
      user: { role: "editor", password: "", password_confirmation: "" }
    }

    assert_redirected_to admin_users_path
    assert @reader.reload.valid_password?("password0924")
  end

  test "admins can reset a user's password" do
    sign_in @admin

    patch admin_user_path(@reader), params: {
      user: { password: "brandnew789", password_confirmation: "brandnew789" }
    }

    assert @reader.reload.valid_password?("brandnew789")
  end

  test "unknown roles are ignored" do
    sign_in @admin

    patch admin_user_path(@editor), params: { user: { role: "superuser" } }

    assert @editor.reload.has_role?(:editor)
  end

  test "admins cannot change their own role" do
    sign_in @admin

    patch admin_user_path(@admin), params: { user: { role: "user" } }

    assert_redirected_to edit_admin_user_path(@admin)
    assert @admin.reload.has_role?(:admin)
  end

  # --- Everyone else is kept out ---

  test "guests are sent to log in" do
    get admin_users_path
    assert_redirected_to new_user_session_path
  end

  test "editors and regular users cannot see the user list" do
    [ @editor, @reader ].each do |user|
      sign_in user
      get admin_users_path
      assert_response :redirect
      assert_not_equal admin_users_path, URI(response.location).path
      sign_out user
    end
  end

  test "non-admins do not see the Manage Users link" do
    sign_in @editor
    get root_path
    assert_select "a[href=?]", admin_users_path, count: 0
  end

  test "non-admins cannot create users" do
    sign_in @editor

    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: { email: "sneaky@marco.com", password: "password456", password_confirmation: "password456", role: "admin" }
      }
    end
  end

  test "non-admins cannot change roles" do
    sign_in @reader

    patch admin_user_path(@reader), params: { user: { role: "admin" } }

    assert_not @reader.reload.has_role?(:admin)
  end
end
