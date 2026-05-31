# frozen_string_literal: true

class ReceivableVersionSerializer
  def initialize(version)
    @version = version
  end

  def as_json(*)
    changes = @version.object_changes
    changes = YAML.safe_load(changes, permitted_classes: [ Date, Time, BigDecimal ]) if changes.is_a?(String)

    {
      id: @version.id,
      receivable_id: @version.item_id,
      event: @version.event,
      changes: changes,
      whodunnit: @version.whodunnit,
      created_at: @version.created_at,
      receivable_amount_cents: @version.try(:receivable_amount_cents),
      receivable_due_date: @version.try(:receivable_due_date)
    }
  end
end
