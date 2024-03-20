class Api::V1::UsersController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: [:login, :create]


  def index
    @users = User.all
    render json: { users: @users, messages: "This is the list of all the users" }, status: :ok
  end

  def show
    @user = User.find(params[:id])
    render json: { user: @user, messages: "This is the user with id: #{params[:id]}" }, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { user: @user, messages: "User created successfully" }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      render json: { user: @user, messages: "User updated successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      render json: { messages: "User deleted successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: params[:user][:email])
    if @user&.valid_password?(params[:user][:password])
      client_app = Doorkeeper::Application.find_by(uid: params[:client_id])
      access_token = Doorkeeper::AccessToken.create!(
        resource_owner_id: @user.id,
        application_id: client_app.id,
        refresh_token: generate_refresh_token,
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        scopes: ''
      )
      render json: { user: @user, access_token: access_token.token, message: 'Login successful' }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    if params[:access_token].present?
      current_token = Doorkeeper::AccessToken.find_by(token: params[:access_token])
      if current_token
        destroyed = current_token.destroy
        if destroyed
          render json: { message: 'Logout successful' }, status: :ok
        else
          render json: { error: 'Failed to destroy access token' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Invalid access token' }, status: :unauthorized
      end
    else
      render json: { error: 'Access token not provided' }, status: :unauthorized
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :username, :phone)
  end

  def generate_refresh_token
    loop do
      token = SecureRandom.hex(32)
      break token unless Doorkeeper::AccessToken.exists?(refresh_token: token)
    end
  end
end
