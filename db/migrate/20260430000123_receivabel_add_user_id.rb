class ReceivabelAddUserId < ActiveRecord::Migration[8.1]
  def change
    add_reference :receivables, :user, type: :uuid, null: false, foreign_key: true
  end
end
