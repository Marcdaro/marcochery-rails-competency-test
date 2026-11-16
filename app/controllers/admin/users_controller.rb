# Lets admins create users, edit them and change their roles.
# Lives under /admin so it stays separate from Devise's own sign-up and account pages.
class Admin::UsersController < ApplicationController
  before_action :authenticate_user!

  # Only admins may reach any action here; everyone else gets "Permission Denied"
  access admin: [ :index, :new, :create, :edit, :update ]

  before_action :set_user, only: [ :edit, :update ]
  before_action :prevent_self_role_change, only: :update

  def index
    @users = User.includes(:articles).order(:email)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "User #{@user.email} was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User #{@user.email} was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = params.require(:user).permit(:email, :password, :password_confirmation, :role)

    # Leaving both password fields blank on the edit form keeps the current password
    if action_name == "update" && permitted[:password].blank? && permitted[:password_confirmation].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end

    # Only accept roles Petergate knows about (:user, :editor, :admin)
    permitted.delete(:role) unless User::ROLES.map(&:to_s).include?(permitted[:role].to_s)

    permitted
  end

  # An admin changing their own role could lock everyone out of this page
  def prevent_self_role_change
    return unless @user == current_user
    return if params.dig(:user, :role).blank? || params.dig(:user, :role).to_s == current_user.role.to_s

    redirect_to edit_admin_user_path(@user), alert: "You can't change your own role."
  end
end
