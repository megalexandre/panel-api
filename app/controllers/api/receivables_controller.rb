# frozen_string_literal: true
require "csv"

class Api::ReceivablesController < Api::BaseController
  include Authenticable

  before_action :load_receivable, only: [ :show, :update, :destroy, :change_status ]

  STATUS_LABELS = {
    "draft"      => "Rascunho",
    "awaiting"   => "Aguardando",
    "to_deposit" => "A depositar",
    "deposited"  => "Depositado",
    "returned"   => "Retornado",
    "overdue"    => "Vencido",
    "paid"       => "Pago"
  }.freeze

  def export
    form = Receivables::ListForm.from_params(params, user_id: current_user_id)
    service_params = form.to_service_params.except(:page, :per_page)
    receivables = Receivables::ListService.all(**service_params)

    receivables_with_users = receivables.includes(:user)

    bom = "\xEF\xBB\xBF"
    csv = bom + "sep=;\n" + CSV.generate(col_sep: ";") do |csv|
      csv << [ "Vencimento", "Valor (R$)", "Status", "Dias p/ vencer", "Data do status", "Observações", "Criado por", "Criado em", "Última alteração" ]
      receivables_with_users.each do |r|
        csv << [
          r.due_date.strftime("%d/%m/%Y"),
          format("%.2f", r.amount_cents / 100.0).tr(".", ","),
          STATUS_LABELS[r.status] || r.status,
          (r.due_date.to_date - Date.current).to_i,
          r.change_date.strftime("%d/%m/%Y"),
          r.notes.to_s,
          r.user.email,
          r.created_at.strftime("%d/%m/%Y"),
          r.updated_at.strftime("%d/%m/%Y")
        ]
      end
    end

    filename = "recebiveis_#{Date.current.strftime('%Y-%m-%d')}.csv"
    send_data csv.encode("UTF-8"),
              filename: filename,
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end

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
