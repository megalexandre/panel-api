class CreateReceivables < ActiveRecord::Migration[8.1]
  def change
    create_table :receivables do |t|
      t.integer :amount_cents
      t.date :due_date
      
      t.timestamps
    end
  end
end
