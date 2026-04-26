class Api::ReceivablesController < Api::BaseController
  include Authenticable

  before_action :load_receivable, only: [:show, :update, :destroy]

  def index
    receivables = Receivables::ListService.call(with_discarded: with_discarded_param?)

    render json: { receivables: receivables.map { |receivable| ReceivableSerializer.new(receivable) } }, status: :ok
  end

  def show
    render_resource(@receivable, ReceivableSerializer, key: :receivable)
  end

  def create
    result = Receivables::CreateService.call(params: receivable_params)
    receivable = result.receivable

    if result.success?
      render_resource(receivable, ReceivableSerializer, status: :created, key: :receivable)
    else
      render json: { errors: receivable.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    result = Receivables::UpdateService.call(receivable: @receivable, params: receivable_params)

    if result.success?
      render_resource(@receivable, ReceivableSerializer, key: :receivable)
    else
      render json: { errors: @receivable.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    Receivables::DestroyService.call(receivable: @receivable)
    head :no_content
  end

  private

  def load_receivable
    @receivable = Receivables::FindService.call(id: params[:id], with_discarded: with_discarded_param?)
    raise Api::ResourceNotFoundError if @receivable.blank?
  end

  def receivable_params
    params.permit(:amount_cents, :amount, :due_date, :status)
  end

  def with_discarded_param?
    ActiveModel::Type::Boolean.new.cast(params[:with_discarded])
  end
end