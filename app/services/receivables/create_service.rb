module Receivables
  class CreateService
    def self.call(params:)
      form = Receivables::CreateForm.new(params)
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?
      Receivable.create!(form.to_attributes)
    end
  end
end
