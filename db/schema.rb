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

ActiveRecord::Schema.define(version: 20160620171718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "average_caches", force: true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "avg",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commontator_comments", force: true do |t|
    t.string   "creator_type"
    t.integer  "creator_id"
    t.string   "editor_type"
    t.integer  "editor_id"
    t.integer  "thread_id",                     null: false
    t.text     "body",                          null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_up",   default: 0
    t.integer  "cached_votes_down", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_comments", ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down", using: :btree
  add_index "commontator_comments", ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up", using: :btree
  add_index "commontator_comments", ["creator_id", "creator_type", "thread_id"], name: "index_commontator_comments_on_c_id_and_c_type_and_t_id", using: :btree
  add_index "commontator_comments", ["thread_id", "created_at"], name: "index_commontator_comments_on_thread_id_and_created_at", using: :btree

  create_table "commontator_subscriptions", force: true do |t|
    t.string   "subscriber_type", null: false
    t.integer  "subscriber_id",   null: false
    t.integer  "thread_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_subscriptions", ["subscriber_id", "subscriber_type", "thread_id"], name: "index_commontator_subscriptions_on_s_id_and_s_type_and_t_id", unique: true, using: :btree
  add_index "commontator_subscriptions", ["thread_id"], name: "index_commontator_subscriptions_on_thread_id", using: :btree

  create_table "commontator_threads", force: true do |t|
    t.string   "commontable_type"
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type"
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_threads", ["commontable_id", "commontable_type"], name: "index_commontator_threads_on_c_id_and_c_type", unique: true, using: :btree

  create_table "cookeds", force: true do |t|
    t.integer  "cooker_id"
    t.integer  "cooked_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cookeds", ["cooked_id"], name: "index_cookeds_on_cooked_id", using: :btree
  add_index "cookeds", ["cooker_id", "cooked_id"], name: "index_cookeds_on_cooker_id_and_cooked_id", unique: true, using: :btree
  add_index "cookeds", ["cooker_id"], name: "index_cookeds_on_cooker_id", using: :btree

  create_table "deferred_ingredients", force: true do |t|
    t.integer  "user_id"
    t.integer  "ingredient_id"
    t.string   "ingredient_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deferred_ingredients", ["user_id"], name: "index_deferred_ingredients_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.string   "start_at"
    t.string   "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipe_name"
    t.integer  "servings"
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
    t.string   "abbreviated"
  end

  create_table "instructions", force: true do |t|
    t.integer  "recipe_id"
    t.text     "description"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructions", ["recipe_id"], name: "index_instructions_on_recipe_id", using: :btree

  create_table "others_photos", force: true do |t|
    t.string  "photo_url"
    t.integer "recipe_id"
    t.integer "user_id"
  end

  add_index "others_photos", ["recipe_id"], name: "index_others_photos_on_recipe_id", using: :btree
  add_index "others_photos", ["user_id"], name: "index_others_photos_on_user_id", using: :btree

  create_table "overall_averages", force: true do |t|
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "overall_avg",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "username"
    t.text     "cookware_preferences"
    t.string   "background_url"
    t.integer  "background_offset"
    t.boolean  "show_full_name"
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
    t.text     "detail"
    t.decimal  "ounces"
  end

  add_index "quantities", ["ingredient_id"], name: "index_quantities_on_ingredient_id", using: :btree
  add_index "quantities", ["recipe_id"], name: "index_quantities_on_recipe_id", using: :btree

  create_table "rates", force: true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "stars",         null: false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id", "rateable_type"], name: "index_rates_on_rateable_id_and_rateable_type", using: :btree
  add_index "rates", ["rater_id"], name: "index_rates_on_rater_id", using: :btree

  create_table "rating_caches", force: true do |t|
    t.integer  "cacheable_id"
    t.string   "cacheable_type"
    t.float    "avg",            null: false
    t.integer  "qty",            null: false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rating_caches", ["cacheable_id", "cacheable_type"], name: "index_rating_caches_on_cacheable_id_and_cacheable_type", using: :btree

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
    t.text     "cookware"
    t.string   "remote_photo_url"
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
    t.string   "username"
    t.string   "age_range"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "birthday"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

end
