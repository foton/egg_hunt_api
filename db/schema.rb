# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160331133705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coordinates", force: :cascade do |t|
    t.decimal "latitude_number",                null: false
    t.decimal "longitude_number",               null: false
    t.string  "latitude_hemisphere",  limit: 1, null: false
    t.string  "longitude_hemisphere", limit: 1, null: false
  end

  add_index "coordinates", ["latitude_hemisphere"], name: "index_coordinates_on_latitude_hemisphere", using: :btree
  add_index "coordinates", ["latitude_number"], name: "index_coordinates_on_latitude_number", using: :btree
  add_index "coordinates", ["longitude_hemisphere"], name: "index_coordinates_on_longitude_hemisphere", using: :btree
  add_index "coordinates", ["longitude_number"], name: "index_coordinates_on_longitude_number", using: :btree

  create_table "eggs", force: :cascade do |t|
    t.integer  "size",        limit: 2, null: false
    t.string   "name",                  null: false
    t.integer  "location_id",           null: false
    t.integer  "user_id",               null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "eggs", ["location_id"], name: "index_eggs_on_location_id", using: :btree
  add_index "eggs", ["name"], name: "index_eggs_on_name", using: :btree
  add_index "eggs", ["size"], name: "index_eggs_on_size", using: :btree
  add_index "eggs", ["user_id"], name: "index_eggs_on_user_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",                       null: false
    t.string   "city"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "top_left_coordinate_id",     null: false
    t.integer  "bottom_right_coordinate_id", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "locations", ["bottom_right_coordinate_id"], name: "index_locations_on_bottom_right_coordinate_id", using: :btree
  add_index "locations", ["city"], name: "index_locations_on_city", using: :btree
  add_index "locations", ["name"], name: "index_locations_on_name", using: :btree
  add_index "locations", ["top_left_coordinate_id"], name: "index_locations_on_top_left_coordinate_id", using: :btree
  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                      null: false
    t.string   "token",                      null: false
    t.boolean  "admin",      default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["token"], name: "index_users_on_token", unique: true, using: :btree

  add_foreign_key "eggs", "locations"
  add_foreign_key "eggs", "users"
  add_foreign_key "locations", "coordinates", column: "bottom_right_coordinate_id"
  add_foreign_key "locations", "coordinates", column: "top_left_coordinate_id"
  add_foreign_key "locations", "users"
end
