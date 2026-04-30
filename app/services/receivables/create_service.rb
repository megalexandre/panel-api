# frozen_string_literal: true
module Receivables
  class CreateService
    def self.call(params:, user_id:)
      form = Receivables::CreateForm.new(params.merge(user_id: user_id))
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?
      Receivable.create!(form.to_attributes)
    end
  end
end
