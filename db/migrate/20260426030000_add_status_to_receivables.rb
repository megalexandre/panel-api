# frozen_string_literal: true
class AddStatusToReceivables < ActiveRecord::Migration[8.1]
  def change
    add_column :receivables, :status, :integer, default: 0, null: false
    add_index :receivables, :status
  end
end
