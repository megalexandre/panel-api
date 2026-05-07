# frozen_string_literal: true
class HolidayOverrideSerializer
  def initialize(override)
    @override = override
  end

  def as_json(*)
    {
      id:         @override.id,
      date:       @override.date,
      holiday:    @override.holiday,
      name:       @override.name,
      created_at: @override.created_at,
      updated_at: @override.updated_at
    }
  end
end
