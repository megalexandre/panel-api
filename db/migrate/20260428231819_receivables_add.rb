class ReceivablesAdd < ActiveRecord::Migration[8.1]
  def change
     add_column :receivables, :change_date, :date
  end
end
