# frozen_string_literal: true

class Api::BorderoController < Api::BaseController
  include Authenticable

  def show
    bordero = Bordero.find_by(id: params[:id], user_id: current_user_id)
    raise Api::ResourceNotFoundError unless bordero

    render json: BorderoSavedSerializer.new(bordero), status: :ok
  end

  def index
    result = Bordero::ListService.call(
      user_id:        current_user_id,
      page:           params[:page],
      per_page:       params[:per_page],
      sort_by:        params[:sort_by],
      sort_direction: params[:sort_direction]
    )

    render json: {
      items:      result[:borderos].map { |b| BorderoSavedSerializer.new(b) },
      pagination: result[:pagination],
      summary:    BorderoSumarizeSerializer.new(result[:borderos])
    }, status: :ok
  end

  def update
    bordero = Bordero::UpdateService.call(id: params[:id], params: update_params, user_id: current_user_id)
    render json: BorderoSavedSerializer.new(bordero), status: :ok
  end

  def save
    bordero = Bordero::SaveService.call(params: save_params, user_id: current_user_id)
    render json: BorderoSavedSerializer.new(bordero), status: :created
  end

  private

  def save_params
    params.permit(*Bordero::SaveForm::PERMITTED_PARAMS).to_h
  end

  def update_params
    params.permit(*Bordero::SaveForm::PERMITTED_PARAMS).to_h
  end
end
