# frozen_string_literal: true
class AddBorderoIdToReceivables < ActiveRecord::Migration[8.1]
  def change
    add_reference :receivables, :bordero, type: :uuid, null: true, foreign_key: true
  end
end
