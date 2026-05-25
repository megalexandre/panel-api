class AddAwaitingDaysToBorderos < ActiveRecord::Migration[8.1]
  def change
    add_column :borderos, :awaiting_days, :integer, default: 0, null: false
  end
end
