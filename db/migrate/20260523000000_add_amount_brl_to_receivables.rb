# frozen_string_literal: true

class AddAmountBrlToReceivables < ActiveRecord::Migration[8.1]
  def change
    add_column :receivables, :amount_brl, :virtual,
               type: :string,
               as: "('R$ ' || (amount_cents / 100)::text || '.' || lpad((amount_cents % 100)::text, 2, '0'))",
               stored: true
  end
end
