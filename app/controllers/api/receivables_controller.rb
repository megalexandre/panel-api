class Api::ReceivablesController < Api::BaseController
  include Authenticable

  def index
    receivables = Receivables::ListService.call

    render json: { receivables: receivables.map { |receivable| ReceivableSerializer.new(receivable) } }, status: :ok
  end

  def show
    receivable = Receivables::FindService.call(id: params[:id])
    return render_not_found unless receivable

    render json: { receivable: ReceivableSerializer.new(receivable) }, status: :ok
  end

  def create
    result = Receivables::CreateService.call(params: receivable_params)
    receivable = result.receivable

    if result.success?
      render json: { message: "Receivable created successfully", receivable: ReceivableSerializer.new(receivable) }, status: :created
    else
      render json: { errors: receivable.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    receivable = Receivables::FindService.call(id: params[:id])
    return render_not_found unless receivable

    result = Receivables::UpdateService.call(receivable: receivable, params: receivable_params)

    if result.success?
      render json: { message: "Receivable updated successfully", receivable: ReceivableSerializer.new(receivable) }, status: :ok
    else
      render json: { errors: receivable.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    receivable = Receivables::FindService.call(id: params[:id])
    return render_not_found unless receivable

    Receivables::DestroyService.call(receivable: receivable)
    head :no_content
  end

  private

  def receivable_params
    permitted = params.permit(:amount_cents, :amount, :due_date)

    if permitted[:amount].present?
      amount_cents = Receivables::AmountParser.to_cents(permitted[:amount])
      permitted[:amount_cents] = amount_cents if amount_cents
    end

    permitted.except(:amount)
  end

  def render_not_found
    render json: { error: "Receivable not found" }, status: :not_found
  end
end