# frozen_string_literal: true

class ReceivableVersionSerializer
  def initialize(version)
    @version = version
  end

  def as_json(*)
    changes = @version.object_changes
    changes = JSON.parse(changes) if changes.is_a?(String)

    {
      id: @version.id,
      receivable_id: @version.item_id,
      event: @version.event,
      changes: changes,
      whodunnit: @version.whodunnit,
      created_at: @version.created_at
    }
  end
end
