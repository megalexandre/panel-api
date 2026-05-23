# frozen_string_literal: true

class ChangeReceivablesStatusToString < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      ALTER TABLE receivables
        ALTER COLUMN status TYPE varchar
        USING CASE status
          WHEN 0 THEN 'awaiting'
          WHEN 1 THEN 'to_deposit'
          WHEN 2 THEN 'deposited'
          WHEN 3 THEN 'returned'
          WHEN 4 THEN 'overdue'
          WHEN 5 THEN 'paid'
        END
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE receivables
        ALTER COLUMN status TYPE integer
        USING CASE status
          WHEN 'awaiting'    THEN 0
          WHEN 'to_deposit'  THEN 1
          WHEN 'deposited'   THEN 2
          WHEN 'returned'    THEN 3
          WHEN 'overdue'     THEN 4
          WHEN 'paid'        THEN 5
        END
    SQL
  end
end
