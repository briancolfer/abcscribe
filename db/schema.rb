# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_14_000428) do
  create_table "behaviors", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "user_id"], name: "index_behaviors_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_behaviors_on_user_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.datetime "occurred_at"
    t.text "consequence"
    t.integer "reinforcement_type"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "antecedent"
    t.text "behavior"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "magic_link_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_magic_link_tokens_on_user_id"
  end

  create_table "observations", force: :cascade do |t|
    t.datetime "observed_at", null: false
    t.text "antecedent", null: false
    t.text "behavior", null: false
    t.text "consequence", null: false
    t.text "notes"
    t.integer "user_id", null: false
    t.integer "subject_id", null: false
    t.integer "setting_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["observed_at"], name: "index_observations_on_observed_at"
    t.index ["setting_id"], name: "index_observations_on_setting_id"
    t.index ["subject_id"], name: "index_observations_on_subject_id"
    t.index ["user_id"], name: "index_observations_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_settings_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.date "date_of_birth"
    t.text "notes"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_subjects_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.string "api_token"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
  end

  add_foreign_key "behaviors", "users"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "magic_link_tokens", "users"
  add_foreign_key "observations", "settings"
  add_foreign_key "observations", "subjects"
  add_foreign_key "observations", "users"
  add_foreign_key "settings", "users"
  add_foreign_key "subjects", "users"
end
