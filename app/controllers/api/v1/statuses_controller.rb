class Api::V1::StatusesController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :set_status, only: [:show, :update, :destroy]

  def index
    @statuses = current_user.statuses
    render json: { statuses: @statuses, message: "This is the list of all the statuses" }, status: :ok
  end

  def show
    render json: { status: @status, message: "This is the status with id: #{params[:id]}" }, status: :ok
  end

  def destroy
    if @status.destroy
      render json: { message: "Status deleted successfully" }, status: :ok
    else
      render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @status.update(status_params)
      render json: { status: @status, message: "Status updated successfully" }, status: :ok
    else
      render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    @status = current_user.statuses.build(status_params)
    if @status.save
      render json: { status: @status, message: "Status created successfully" }, status: :created
    else
      render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_status
    @status = current_user.statuses.find(params[:id])
  end

  def status_params
    params.require(:status).permit(:content, :author)
  end

end
