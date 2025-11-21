class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :slug, null: false, index: { unique: true }
      t.integer :privacy, default: 0
      t.boolean :is_active, default: true
      t.string :cover_image
      t.timestamps
    end
  end
end

