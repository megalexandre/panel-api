# frozen_string_literal: true

class Api::ReceivableAuditsController < Api::BaseController
  include Authenticable

  PER_PAGE = 30

  def index
    page = (params[:page] || 1).to_i
    per  = (params[:per_page] || PER_PAGE).to_i

    versions = PaperTrail::Version
      .where(item_type: "Receivable")
      .joins("JOIN receivables ON receivables.id = versions.item_id")
      .where(receivables: { user_id: current_user_id })
      .where.not(receivables: { status: "draft" })
      .order(created_at: :desc)
      .offset((page - 1) * per)
      .limit(per)

    total = PaperTrail::Version
      .where(item_type: "Receivable")
      .joins("JOIN receivables ON receivables.id = versions.item_id")
      .where(receivables: { user_id: current_user_id })
      .where.not(receivables: { status: "draft" })
      .count

    render json: {
      versions: versions.map { |v| ReceivableVersionSerializer.new(v) },
      pagination: { page: page, per_page: per, total: total }
    }, status: :ok
  end
end
