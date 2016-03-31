class CreateEggs < ActiveRecord::Migration
  def change
    create_table :eggs do |t|
      t.integer :size, null: false, index: true
      t.string :name, null: false, index: true
      t.reference :location, null: false, index: true
      t.reference :user, null: false, index: true

      t.timestamps null: false
    end
    add_foreign_key :eggs, :users, column: :user_id
    add_foreign_key :eggs, :locations, column: :location_id
  end
end
