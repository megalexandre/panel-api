# frozen_string_literal: true
module HolidayOverrides
  class UpdateService
    Result = Struct.new(:success?, keyword_init: true)

    def self.call(override:, params:)
      form = HolidayOverrides::UpdateForm.from_params(params)
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      success = override.update(form.to_attributes)
      Result.new("success?": success)
    end
  end
end
