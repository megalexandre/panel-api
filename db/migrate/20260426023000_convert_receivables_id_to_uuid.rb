# frozen_string_literal: true
class ConvertReceivablesIdToUuid < ActiveRecord::Migration[8.1]
  def up
    add_column :receivables, :uuid, :uuid, default: "gen_random_uuid()", null: false

    execute "ALTER TABLE receivables DROP CONSTRAINT receivables_pkey"
    rename_column :receivables, :id, :integer_id
    rename_column :receivables, :uuid, :id
    execute "ALTER TABLE receivables ADD PRIMARY KEY (id)"

    remove_column :receivables, :integer_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot safely restore integer primary keys once converted to UUID"
  end
end