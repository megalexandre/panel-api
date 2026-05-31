class AddSequenceNumberToReceivablesAndBorderos < ActiveRecord::Migration[8.1]
  def up
    add_column :receivables, :sequence_number, :integer
    add_column :borderos, :sequence_number, :integer

    # Backfill: assign sequential numbers per user ordered by created_at
    execute <<~SQL
      UPDATE receivables r
      SET sequence_number = seq.rn
      FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS rn
        FROM receivables
      ) seq
      WHERE r.id = seq.id
    SQL

    execute <<~SQL
      UPDATE borderos b
      SET sequence_number = seq.rn
      FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS rn
        FROM borderos
      ) seq
      WHERE b.id = seq.id
    SQL

    change_column_null :receivables, :sequence_number, false
    change_column_null :borderos, :sequence_number, false

    add_index :receivables, %i[user_id sequence_number], unique: true
    add_index :borderos, %i[user_id sequence_number], unique: true
  end

  def down
    remove_index :receivables, %i[user_id sequence_number]
    remove_index :borderos, %i[user_id sequence_number]
    remove_column :receivables, :sequence_number
    remove_column :borderos, :sequence_number
  end
end
