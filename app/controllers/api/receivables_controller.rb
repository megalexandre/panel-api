# frozen_string_literal: true

class Api::ReceivablesController < Api::BaseController
  include Authenticable

  before_action :load_receivable, only: [ :show, :update, :destroy, :change_status ]

  def index
    form = Receivables::ListForm.from_params(params, user_id: current_user_id)
    result = Receivables::ListService.call(**form.to_service_params)

    render json: {
      receivables: result[:receivables].map { |receivable| ReceivableSerializer.new(receivable) },
      pagination: result[:pagination],
      summary: result[:summary]
    }, status: :ok
  end

  def show
    render json: ReceivableSerializer.new(@receivable), status: :ok
  end

  def create
    receivable = Receivables::CreateService.call(params: create_params.to_h, user_id: current_user_id)
    render json: ReceivableSerializer.new(receivable), status: :created
  end

  def update
    result = Receivables::UpdateService.call(receivable: @receivable, params: receivable_params)
    render_result(result, @receivable, ReceivableSerializer)
  end

  def destroy
    @receivable.soft_delete!
    head :no_content
  end

  def change_status
    result = Receivables::ChangeStatusService.call(receivable: @receivable, status: params[:status])
    render_result(result, @receivable, ReceivableSerializer)
  end

  private

  def load_receivable
    with_discarded = ActiveModel::Type::Boolean.new.cast(params[:with_discarded])
    @receivable = Receivables::FindService.call(id: params[:id], user_id: current_user_id, with_discarded: with_discarded)
    raise Api::ResourceNotFoundError if @receivable.blank?
  end

  def create_params
    params.permit(Receivables::CreateForm::PERMITTED_ATTRIBUTES)
  end

  def receivable_params
    params.permit(:amount_cents, :amount, :due_date, :status, :change_date, :notes)
  end
end
