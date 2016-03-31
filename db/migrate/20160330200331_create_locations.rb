class CreateLocations < ActiveRecord::Migration
  def change
    create_table :coordinates do |t|
      t.decimal :latitude_number, null: false, index: true
      t.decimal :longitude_number, null: false, index: true
      t.string :latitude_hemisphere, limit: 1, null: false, index: true
      t.string :longitude_hemisphere, limit: 1, null: false, index: true
    end	

    create_table :locations do |t|
    	t.string :name, null: false, index: true
      t.string :city, index: true
      t.text :description
      t.belongs_to :user, null: true, index: true   #location is leaved nullified after user delete
      t.integer :top_left_coordinate_id, null: false, index: true
      t.integer :bottom_right_coordinate_id, null: false, index: true

      t.timestamps null: false
    end
    
    add_foreign_key :locations, :users, column: :user_id
    add_foreign_key :locations, :coordinates, column: :top_left_coordinate_id
    add_foreign_key :locations, :coordinates, column: :bottom_right_coordinate_id
    
  end
end
