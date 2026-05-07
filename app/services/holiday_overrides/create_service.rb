# frozen_string_literal: true
module HolidayOverrides
  class CreateService
    def self.call(params:)
      form = HolidayOverrides::CreateForm.from_params(params)
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      HolidayOverride.create!(form.to_attributes)
    end
  end
end
