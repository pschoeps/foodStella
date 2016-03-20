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

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20160320162310) do
=======
ActiveRecord::Schema.define(version: 20160314224354) do
>>>>>>> 2cac660af8aa843734fc9503e6a68cebe3a0424e

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

<<<<<<< HEAD
  create_table "ingredients", force: true do |t|
    t.string   "name"
=======
  create_table "recipes", force: true do |t|
    t.string   "name"
    t.integer  "prep_time"
    t.integer  "cook_time"
    t.integer  "user_id",                  null: false
    t.integer  "ingredients", default: [],              array: true
>>>>>>> 2cac660af8aa843734fc9503e6a68cebe3a0424e
    t.datetime "created_at"
    t.datetime "updated_at"
  end

<<<<<<< HEAD
  create_table "quantities", force: true do |t|
    t.string   "amount"
    t.string   "decimal"
    t.string   "ingredient"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipe_id"
    t.integer  "ingredient_id"
  end

  add_index "quantities", ["ingredient_id"], name: "index_quantities_on_ingredient_id", using: :btree
  add_index "quantities", ["recipe_id"], name: "index_quantities_on_recipe_id", using: :btree

  create_table "recipes", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "photo_url"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "instructions"
  end

  add_index "recipes", ["user_id"], name: "index_recipes_on_user_id", using: :btree

=======
  create_table "tests", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

>>>>>>> 2cac660af8aa843734fc9503e6a68cebe3a0424e
  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
