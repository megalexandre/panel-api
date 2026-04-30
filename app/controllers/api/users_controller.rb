# frozen_string_literal: true
class Api::UsersController < Api::BaseController
  include Authenticable

  skip_before_action :authenticate_request!, only: [:create]

  def create
    user = User.new(user_params)

    if user.save
      render json: { message: "User created successfully", user: UserSerializer.new(user) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def me
    render json: { user: UserSerializer.new(current_user) }, status: :ok
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
