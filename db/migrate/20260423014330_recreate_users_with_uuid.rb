# frozen_string_literal: true
class RecreateUsersWithUuid < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    drop_table :users

    create_table :users, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.json :roles, default: ['user']

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
