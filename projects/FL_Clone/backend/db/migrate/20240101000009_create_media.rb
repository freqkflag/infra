class CreateMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :media do |t|
      t.references :user, null: false, foreign_key: true
      t.references :attachable, polymorphic: true
      t.string :file_type, null: false
      t.integer :privacy, default: 0
      t.text :caption
      t.timestamps
    end
    
    add_index :media, [:attachable_type, :attachable_id]
  end
end

