# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110110202259) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.float    "calories_burned_per_pound_per_minute"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "exercise_clips", :force => true do |t|
    t.integer  "exercise_id"
    t.string   "clip_file_name"
    t.string   "clip_content_type"
    t.string   "reps"
    t.integer  "clip_file_size"
    t.integer  "seconds"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exercise_clips", ["exercise_id"], :name => "index_exercise_clips_on_exercise_id"

  create_table "exercises", :force => true do |t|
    t.string  "name",           :null => false
    t.string  "description"
    t.integer "musclegroup_id", :null => false
  end

  add_index "exercises", ["musclegroup_id"], :name => "index_exercises_on_musclegroup_id"

  create_table "exercises_workouts", :force => true do |t|
    t.integer "exercise_id",                         :null => false
    t.integer "exercise_clip_id"
    t.integer "workout_id",                          :null => false
    t.integer "display_order",    :default => 99999
    t.string  "weight"
    t.integer "delay_time",       :default => 5
  end

  add_index "exercises_workouts", ["display_order"], :name => "index_exercises_workouts_on_display_order"
  add_index "exercises_workouts", ["workout_id"], :name => "index_exercises_workouts_on_workout_id"

  create_table "favorite_activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_activities", ["activity_id"], :name => "index_favorite_activities_on_activity_id"
  add_index "favorite_activities", ["user_id"], :name => "index_favorite_activities_on_user_id"

  create_table "favorite_foods", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_foods", ["user_id"], :name => "index_favorite_foods_on_user_id"

  create_table "food_items", :force => true do |t|
    t.integer  "favorite_food_id"
    t.integer  "user_id"
    t.string   "food_id"
    t.integer  "serving_id"
    t.integer  "servings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "meal_id"
  end

  add_index "food_items", ["meal_id"], :name => "index_food_items_on_meal_id"

  create_table "freebies", :force => true do |t|
    t.string   "email"
    t.string   "key"
    t.boolean  "used"
    t.string   "membership_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meals", :force => true do |t|
    t.integer  "user_id"
    t.string   "food_id"
    t.integer  "serving_id"
    t.float    "servings"
    t.string   "food_name"
    t.string   "food_type"
    t.string   "serving_description"
    t.string   "brand_name"
    t.float    "serving_amount"
    t.float    "calories"
    t.float    "carbohydrate"
    t.float    "protein"
    t.float    "fat"
    t.float    "saturated_fat"
    t.float    "polyunsaturated_fat"
    t.float    "monosaturated_fat"
    t.float    "trans_fat"
    t.float    "cholesterol"
    t.float    "sodium"
    t.float    "potassium"
    t.float    "fiber"
    t.float    "sugar"
    t.float    "vitamin_a"
    t.float    "vitamin_c"
    t.float    "calcium"
    t.float    "iron"
    t.string   "meal_name"
    t.datetime "eaten_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meals", ["eaten_at"], :name => "index_meals_on_eaten_at"
  add_index "meals", ["user_id"], :name => "index_meals_on_user_id"

  create_table "medical_histories", :force => true do |t|
    t.integer  "user_id"
    t.string   "p_name"
    t.string   "p_number"
    t.string   "health"
    t.string   "fitness"
    t.string   "exercise"
    t.string   "contact_p"
    t.string   "illness"
    t.string   "problems"
    t.string   "bone"
    t.string   "pain"
    t.string   "medication"
    t.string   "routine"
    t.date     "p_visit"
    t.text     "p_visit_text"
    t.text     "exercise_text"
    t.text     "illness_text"
    t.text     "problems_text"
    t.text     "bone_text"
    t.text     "pain_text"
    t.text     "medication_text"
    t.text     "routine_text"
    t.text     "experience"
    t.text     "diagnose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "medical_histories", ["user_id"], :name => "index_medical_histories_on_user_id"

  create_table "musclegroups", :force => true do |t|
    t.string "name"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "chargify_id"
    t.string   "state"
    t.string   "product"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "subscription_id"
    t.float    "amount"
    t.boolean  "success"
    t.boolean  "test"
    t.string   "reference"
    t.string   "message"
    t.string   "action"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.string   "name"
    t.float    "duration"
    t.float    "calories_burned"
    t.datetime "activity_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_activities", ["activity_date"], :name => "index_user_activities_on_activity_date"
  add_index "user_activities", ["user_id"], :name => "index_user_activities_on_user_id"

  create_table "user_bucket_exercises", :force => true do |t|
    t.integer  "user_bucket_id"
    t.integer  "exercise_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_bucket_exercises", ["exercise_id"], :name => "index_user_bucket_exercises_on_exercise_id"
  add_index "user_bucket_exercises", ["user_bucket_id"], :name => "index_user_bucket_exercises_on_user_bucket_id"

  create_table "user_buckets", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",      :default => false
    t.integer  "display_order"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

  create_table "user_weights", :force => true do |t|
    t.integer  "user_id"
    t.integer  "weight"
    t.integer  "weight_image_file_size"
    t.string   "weight_image_file_name"
    t.string   "weight_image_content_type"
    t.datetime "weight_image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_weights", ["created_at"], :name => "index_user_weights_on_created_at"
  add_index "user_weights", ["user_id"], :name => "index_user_weights_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_salt"
    t.string   "password_hash"
    t.date     "birthday"
    t.string   "home_phone"
    t.string   "cell_phone"
    t.string   "height"
    t.integer  "weight"
    t.text     "goals"
    t.text     "equipment"
    t.string   "sex"
    t.integer  "target_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_logged_in_at"
    t.string   "time_zone"
    t.string   "fitness_level"
    t.integer  "user_bucket_id"
    t.string   "workout_difficulty"
    t.boolean  "reminder_emails",    :default => true
    t.boolean  "promotional_emails", :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "wait_list_users", :force => true do |t|
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workout_sessions", :force => true do |t|
    t.integer  "workout_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_played"
    t.boolean  "complete"
  end

  add_index "workout_sessions", ["workout_id"], :name => "index_workout_sessions_on_workout_id"

  create_table "workout_skeleton_musclegroups", :force => true do |t|
    t.integer  "workout_skeleton_id"
    t.integer  "musclegroup_id"
    t.integer  "display_order",       :default => 99999
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workout_skeleton_musclegroups", ["musclegroup_id"], :name => "index_workout_skeleton_musclegroups_on_musclegroup_id"
  add_index "workout_skeleton_musclegroups", ["workout_skeleton_id"], :name => "index_workout_skeleton_musclegroups_on_workout_skeleton_id"

  create_table "workout_skeletons", :force => true do |t|
    t.integer  "user_bucket_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workout_skeletons", ["user_bucket_id"], :name => "index_workout_skeletons_on_user_bucket_id"

  create_table "workouts", :force => true do |t|
    t.integer  "user_id"
    t.date     "week_of"
    t.boolean  "approved",            :default => false
    t.text     "comment"
    t.integer  "repeat_count",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
    t.integer  "workout_skeleton_id"
  end

  add_index "workouts", ["user_id"], :name => "index_workouts_on_user_id"
  add_index "workouts", ["week_of"], :name => "index_workouts_on_week_of"

end
