# frozen_string_literal: true
class CreateHolidayOverrides < ActiveRecord::Migration[8.1]
  def change
    create_table :holiday_overrides, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.date    :date,    null: false
      t.boolean :holiday, null: false
      t.string  :name

      t.timestamps
    end

    add_index :holiday_overrides, :date, unique: true
  end
end
