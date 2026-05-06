# frozen_string_literal: true

module Receivables
  class ListForm
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[with_discarded page per_page sort_by sort_direction].freeze
    attr_accessor(*PERMITTED_ATTRIBUTES, :user_id)

    def self.from_params(params, user_id:)
      form = new(params.permit(*PERMITTED_ATTRIBUTES))
      form.user_id = user_id
      form
    end

    def to_service_params
      {
        user_id: user_id,
        with_discarded: ActiveModel::Type::Boolean.new.cast(with_discarded),
        page: page,
        per_page: per_page,
        sort_by: sort_by,
        sort_direction: sort_direction
      }
    end
  end
end
