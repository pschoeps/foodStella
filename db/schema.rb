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

ActiveRecord::Schema.define(version: 20160501192906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "deferred_foods", force: true do |t|
    t.integer  "user_id"
    t.integer  "food_id"
    t.string   "food_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deferred_foods", ["user_id"], name: "index_deferred_foods_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.string   "start_at"
    t.string   "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipe_name"
  end

  add_index "events", ["recipe_id"], name: "index_events_on_recipe_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "accepted_at"
    t.datetime "updated_at"
  end

  create_table "ingredients", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructions", force: true do |t|
    t.integer  "recipe_id"
    t.text     "description"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructions", ["recipe_id"], name: "index_instructions_on_recipe_id", using: :btree

  create_table "preferred_foods", force: true do |t|
    t.integer  "user_id"
    t.integer  "food_id"
    t.string   "food_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferred_foods", ["user_id"], name: "index_preferred_foods_on_user_id", using: :btree

  create_table "preferred_ingredients", force: true do |t|
    t.integer  "user_id"
    t.integer  "ingredient_id"
    t.string   "ingredient_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferred_ingredients", ["user_id"], name: "index_preferred_ingredients_on_user_id", using: :btree

  create_table "profiles", force: true do |t|
    t.string   "fir_name"
    t.string   "las_name"
    t.string   "email"
    t.string   "country"
    t.text     "about_me"
    t.string   "picture_url"
    t.integer  "cooking_experience"
    t.integer  "average_cook_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "liked_foods"
    t.text     "disliked_foods"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "quantities", force: true do |t|
    t.string   "amount"
    t.string   "decimal"
    t.string   "ingredient"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipe_id"
    t.integer  "ingredient_id"
    t.string   "unit"
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
    t.text     "description"
    t.integer  "prep_time"
    t.integer  "cook_time"
    t.string   "difficulty"
    t.string   "meal_type"
    t.integer  "servings"
    t.string   "website_url"
  end

  add_index "recipes", ["user_id"], name: "index_recipes_on_user_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                       default: "", null: false
    t.string   "encrypted_password",          default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.string   "name"
    t.string   "fir_name"
    t.string   "las_name"
    t.string   "location"
    t.string   "about_me"
    t.string   "hometown"
    t.string   "country"
    t.integer  "day_counter",                 default: 3
    t.datetime "day_counter_last_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
