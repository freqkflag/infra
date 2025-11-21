class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :bio
      t.string :location
      t.string :website
      t.string :role
      t.string :orientation
      t.text :interests, array: true, default: []
      t.text :fetishes, array: true, default: []
      t.integer :privacy_level, default: 0
      t.boolean :show_location, default: true
      t.boolean :show_age, default: true
      t.timestamps
    end
  end
end

