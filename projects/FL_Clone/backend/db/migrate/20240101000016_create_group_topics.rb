class CreateGroupTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :group_topics do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.boolean :is_pinned, default: false
      t.boolean :is_locked, default: false
      t.integer :views_count, default: 0
      t.integer :comments_count, default: 0
      t.timestamps
    end
    
    add_index :group_topics, [:group_id, :created_at]
  end
end

