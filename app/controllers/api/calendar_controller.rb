# frozen_string_literal: true
class Api::CalendarController < Api::BaseController
  include Authenticable

  before_action :validate_form

  def index
    days = Calendar::BuildService.call(year: @form.year_i, month: @form.month_i)
    render json: CalendarSerializer.new(days, year: @form.year_i, month: @form.month_i), status: :ok
  end

  private

  def validate_form
    @form = Calendar::IndexForm.from_params(params)
    raise Api::ValidationError.new(@form.errors.messages) unless @form.valid?
  end
end
