# frozen_string_literal: true
class AddNotesToReceivables < ActiveRecord::Migration[8.1]
  def change
    add_column :receivables, :notes, :text
  end
end
