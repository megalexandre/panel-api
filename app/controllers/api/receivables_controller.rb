class Api::ReceivablesController < Api::BaseController
  include Authenticable

  before_action :load_receivable, only: [ :show, :update, :destroy ]

  def index
    result = Receivables::ListService.call(
      with_discarded: with_discarded_param?,
      page: page_param,
      per_page: per_page_param,
      sort_by: sort_by_param,
      sort_direction: sort_direction_param
    )

    render json: {
      receivables: result[:receivables].map { |receivable| ReceivableSerializer.new(receivable) },
      pagination: result[:pagination]
    }, status: :ok
  end

  def show
    render json: ReceivableSerializer.new(@receivable), status: :ok
  end

  def create
    receivable = Receivables::CreateService.call(params: create_params.to_h)
    render json: ReceivableSerializer.new(receivable), status: :created
  end

  def update
    result = Receivables::UpdateService.call(receivable: @receivable, params: receivable_params)
    render_result(result, @receivable, ReceivableSerializer)
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

  def create_params
    params.permit(Receivables::CreateForm::PERMITTED_ATTRIBUTES)
  end

  def with_discarded_param?
    ActiveModel::Type::Boolean.new.cast(params[:with_discarded])
  end

  def page_param
    params[:page]
  end

  def per_page_param
    params[:per_page]
  end

  def sort_by_param
    params[:sort_by]
  end

  def sort_direction_param
    params[:sort_direction]
  end
end