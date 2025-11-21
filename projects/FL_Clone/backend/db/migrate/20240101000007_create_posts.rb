class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :privacy, default: 0
      t.boolean :is_pinned, default: false
      t.integer :likes_count, default: 0
      t.integer :comments_count, default: 0
      t.timestamps
    end
    
    add_index :posts, [:user_id, :created_at]
    add_index :posts, :privacy
  end
end

