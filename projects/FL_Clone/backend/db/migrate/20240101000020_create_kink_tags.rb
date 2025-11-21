class CreateKinkTags < ActiveRecord::Migration[7.1]
  def change
    create_table :kink_tags do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :slug, null: false, index: { unique: true }
      t.text :description
      t.string :category
      t.integer :usage_count, default: 0
      t.boolean :is_nsfw, default: true
      t.timestamps
    end
    
    create_table :kink_taggings do |t|
      t.references :kink_tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.timestamps
    end
    
    add_index :kink_taggings, [:taggable_type, :taggable_id]
    add_index :kink_taggings, [:kink_tag_id, :taggable_type, :taggable_id], unique: true, name: 'index_kink_taggings_unique'
  end
end

