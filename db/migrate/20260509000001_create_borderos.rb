# frozen_string_literal: true
class CreateBorderos < ActiveRecord::Migration[8.1]
  def change
    create_table :borderos, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.date    :change_date,                 null: false
      t.decimal :monthly_rate_percent,        null: false, precision: 10, scale: 4
      t.integer :total_amount_cents,          null: false
      t.integer :total_proceeds_cents,        null: false
      t.integer :total_interest_amount_cents, null: false
      t.decimal :average_days,               null: false, precision: 10, scale: 2
      t.timestamps
    end
  end
end
