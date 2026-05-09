# frozen_string_literal: true
class Api::BorderoController < Api::BaseController
  include Authenticable

  before_action :validate_form, only: :calculate

  def calculate
    result = Bordero::CalculateService.call(params: calculate_params)
    render json: BorderoSerializer.new(result), status: :ok
  end

  def save
    bordero = Bordero::SaveService.call(params: save_params, user_id: current_user_id)
    render json: BorderoSavedSerializer.new(bordero), status: :created
  end

  private

  def validate_form
    form = Bordero::CalculateForm.new(calculate_params)
    raise Api::ValidationError.new(form.errors.messages) unless form.valid?
  end

  def calculate_params
    params.permit(*Bordero::CalculateForm::PERMITTED_PARAMS).to_h
  end

  def save_params
    params.permit(*Bordero::SaveForm::PERMITTED_PARAMS).to_h
  end
end
