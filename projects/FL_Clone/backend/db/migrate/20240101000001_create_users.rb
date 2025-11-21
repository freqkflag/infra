class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username, null: false, index: { unique: true }
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.boolean :email_verified, default: false
      t.boolean :is_admin, default: false
      t.boolean :is_active, default: true
      t.date :birth_date, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.timestamps
    end
  end
end

