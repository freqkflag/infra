class CreateRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :relationships do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0
      t.timestamps
    end
    
    add_index :relationships, [:follower_id, :followed_id], unique: true
    add_index :relationships, :followed_id
  end
end

