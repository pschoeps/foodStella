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

ActiveRecord::Schema.define(version: 20160918171147) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "average_caches", force: :cascade do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type", limit: 255
    t.float    "avg",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commontator_comments", force: :cascade do |t|
    t.string   "creator_type",      limit: 255
    t.integer  "creator_id"
    t.string   "editor_type",       limit: 255
    t.integer  "editor_id"
    t.integer  "thread_id",                                 null: false
    t.text     "body",                                      null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_up",               default: 0
    t.integer  "cached_votes_down",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down", using: :btree
    t.index ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up", using: :btree
    t.index ["creator_id", "creator_type", "thread_id"], name: "index_commontator_comments_on_c_id_and_c_type_and_t_id", using: :btree
    t.index ["thread_id", "created_at"], name: "index_commontator_comments_on_thread_id_and_created_at", using: :btree
  end

  create_table "commontator_subscriptions", force: :cascade do |t|
    t.string   "subscriber_type", limit: 255, null: false
    t.integer  "subscriber_id",               null: false
    t.integer  "thread_id",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["subscriber_id", "subscriber_type", "thread_id"], name: "index_commontator_subscriptions_on_s_id_and_s_type_and_t_id", unique: true, using: :btree
    t.index ["thread_id"], name: "index_commontator_subscriptions_on_thread_id", using: :btree
  end

  create_table "commontator_threads", force: :cascade do |t|
    t.string   "commontable_type", limit: 255
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type",      limit: 255
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commontable_id", "commontable_type"], name: "index_commontator_threads_on_c_id_and_c_type", unique: true, using: :btree
  end

  create_table "cookeds", force: :cascade do |t|
    t.integer  "cooker_id"
    t.integer  "cooked_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cooked_id"], name: "index_cookeds_on_cooked_id", using: :btree
    t.index ["cooker_id", "cooked_id"], name: "index_cookeds_on_cooker_id_and_cooked_id", unique: true, using: :btree
    t.index ["cooker_id"], name: "index_cookeds_on_cooker_id", using: :btree
  end

  create_table "deferred_ingredients", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "ingredient_id"
    t.string   "ingredient_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_deferred_ingredients_on_user_id", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.string   "start_at",    limit: 255
    t.string   "end_at",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipe_name", limit: 255
    t.integer  "servings"
    t.index ["recipe_id"], name: "index_events_on_recipe_id", using: :btree
    t.index ["user_id"], name: "index_events_on_user_id", using: :btree
  end

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "status",      limit: 255
    t.datetime "created_at"
    t.datetime "accepted_at"
    t.datetime "updated_at"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviated", limit: 255
    t.decimal  "calories"
    t.string   "category"
  end

  create_table "instructions", force: :cascade do |t|
    t.integer  "recipe_id"
    t.text     "description"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["recipe_id"], name: "index_instructions_on_recipe_id", using: :btree
  end

  create_table "others_photos", force: :cascade do |t|
    t.string  "photo_url", limit: 255
    t.integer "recipe_id"
    t.integer "user_id"
    t.index ["recipe_id"], name: "index_others_photos_on_recipe_id", using: :btree
    t.index ["user_id"], name: "index_others_photos_on_user_id", using: :btree
  end

  create_table "overall_averages", force: :cascade do |t|
    t.integer  "rateable_id"
    t.string   "rateable_type", limit: 255
    t.float    "overall_avg",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferred_ingredients", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "ingredient_id"
    t.string   "ingredient_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_preferred_ingredients_on_user_id", using: :btree
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "fir_name",             limit: 255
    t.string   "las_name",             limit: 255
    t.string   "email",                limit: 255
    t.string   "country",              limit: 255
    t.text     "about_me"
    t.string   "picture_url",          limit: 255
    t.integer  "cooking_experience"
    t.integer  "average_cook_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "liked_foods"
    t.text     "disliked_foods"
    t.string   "username",             limit: 255
    t.text     "cookware_preferences"
    t.string   "background_url",       limit: 255
    t.integer  "background_offset"
    t.boolean  "show_full_name"
    t.index ["user_id"], name: "index_profiles_on_user_id", using: :btree
  end

  create_table "quantities", force: :cascade do |t|
    t.string   "amount",        limit: 255
    t.string   "decimal",       limit: 255
    t.string   "ingredient",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipe_id"
    t.integer  "ingredient_id"
    t.string   "unit",          limit: 255
    t.text     "detail"
    t.decimal  "ounces"
    t.index ["ingredient_id"], name: "index_quantities_on_ingredient_id", using: :btree
    t.index ["recipe_id"], name: "index_quantities_on_recipe_id", using: :btree
  end

  create_table "rates", force: :cascade do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type", limit: 255
    t.float    "stars",                     null: false
    t.string   "dimension",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["rateable_id", "rateable_type"], name: "index_rates_on_rateable_id_and_rateable_type", using: :btree
    t.index ["rater_id"], name: "index_rates_on_rater_id", using: :btree
  end

  create_table "rating_caches", force: :cascade do |t|
    t.integer  "cacheable_id"
    t.string   "cacheable_type", limit: 255
    t.float    "avg",                        null: false
    t.integer  "qty",                        null: false
    t.string   "dimension",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cacheable_id", "cacheable_type"], name: "index_rating_caches_on_cacheable_id_and_cacheable_type", using: :btree
  end

  create_table "recipes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",             limit: 255
    t.string   "photo_url",        limit: 255
    t.string   "category",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "prep_time"
    t.integer  "cook_time"
    t.string   "difficulty",       limit: 255
    t.string   "meal_type",        limit: 255
    t.integer  "servings"
    t.string   "website_url",      limit: 255
    t.text     "cookware"
    t.string   "remote_photo_url", limit: 255
    t.index ["user_id"], name: "index_recipes_on_user_id", using: :btree
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
    t.index ["follower_id"], name: "index_relationships_on_follower_id", using: :btree
  end

  create_table "user_preferences", force: :cascade do |t|
    t.boolean  "liked"
    t.string   "token"
    t.integer  "recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_user_preferences_on_recipe_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                       limit: 255, default: "", null: false
    t.string   "encrypted_password",          limit: 255, default: "", null: false
    t.string   "reset_password_token",        limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "provider",                    limit: 255
    t.string   "uid",                         limit: 255
    t.string   "image",                       limit: 255
    t.string   "name",                        limit: 255
    t.string   "fir_name",                    limit: 255
    t.string   "las_name",                    limit: 255
    t.string   "location",                    limit: 255
    t.string   "about_me",                    limit: 255
    t.string   "hometown",                    limit: 255
    t.string   "country",                     limit: 255
    t.integer  "day_counter",                             default: 3
    t.datetime "day_counter_last_updated_at"
    t.string   "username",                    limit: 255
    t.string   "age_range",                   limit: 255
    t.string   "confirmation_token",          limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "birthday"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type", limit: 255
    t.integer  "voter_id"
    t.string   "voter_type",   limit: 255
    t.boolean  "vote_flag"
    t.string   "vote_scope",   limit: 255
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  end

end
