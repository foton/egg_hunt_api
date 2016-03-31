class CreateEggs < ActiveRecord::Migration
  def change
    create_table :eggs do |t|
      t.integer :size, null: false, index: true, limit: 1
      t.string :name, null: false, index: true
      t.belongs_to :location, null: false, index: true
      t.belongs_to :user, null: false, index: true

      t.timestamps null: false
    end
    add_foreign_key :eggs, :users, column: :user_id
    add_foreign_key :eggs, :locations, column: :location_id
  end
end
