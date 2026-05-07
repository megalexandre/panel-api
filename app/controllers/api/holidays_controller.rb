# frozen_string_literal: true
class Api::HolidaysController < Api::BaseController
  include Authenticable

  before_action :authenticate_request!
  before_action :validate_index_form, only: [:index]
  before_action :load_override, only: [:update, :destroy]

  def index
    days = Calendar::BuildService.call(year: @form.year_i, month: @form.month_i)
    render json: CalendarSerializer.new(days, year: @form.year_i, month: @form.month_i), status: :ok
  end

  def create
    override = HolidayOverrides::CreateService.call(params: holiday_params)
    render json: HolidayOverrideSerializer.new(override), status: :created
  end

  def update
    result = HolidayOverrides::UpdateService.call(override: @override, params: holiday_params)
    render_result(result, @override, HolidayOverrideSerializer)
  end

  def destroy
    @override.destroy!
    head :no_content
  end

  private

  def validate_index_form
    @form = Calendar::IndexForm.from_params(params)
    raise Api::ValidationError.new(@form.errors.messages) unless @form.valid?
  end

  def load_override
    @override = HolidayOverride.find_by(id: params[:id])
    raise Api::ResourceNotFoundError unless @override
  end

  def holiday_params
    params.permit(:date, :holiday, :name)
  end
end
