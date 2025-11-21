class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.string :location
      t.string :venue
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :privacy, default: 0
      t.integer :max_attendees
      t.boolean :is_active, default: true
      t.string :cover_image
      t.timestamps
    end
    
    add_index :events, :start_time
  end
end

