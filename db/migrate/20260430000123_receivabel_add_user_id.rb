# frozen_string_literal: true
class ReceivabelAddUserId < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:receivables, :user_id)
      add_reference :receivables, :user, type: :uuid, null: true, foreign_key: true
    end
  end
end