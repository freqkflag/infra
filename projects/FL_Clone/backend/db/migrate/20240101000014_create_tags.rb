class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :slug, null: false, index: { unique: true }
      t.integer :usage_count, default: 0
      t.timestamps
    end
  end
end

