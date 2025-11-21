class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: false
      t.text :content, null: false
      t.references :parent, foreign_key: { to_table: :comments }
      t.integer :likes_count, default: 0
      t.timestamps
    end
    
    add_index :comments, [:commentable_type, :commentable_id]
  end
end

