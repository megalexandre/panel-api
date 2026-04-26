class AddDeletedAtToReceivables < ActiveRecord::Migration[8.1]
  def change
    add_column :receivables, :deleted_at, :datetime
    add_index :receivables, :deleted_at
  end
end