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

ActiveRecord::Schema.define(version: 20150907192559) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "pg_trgm"

  create_table "admins", force: :cascade do |t|
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

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "sex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "age_min"
    t.integer  "age_max"
  end

  create_table "merge_runners_requests", force: :cascade do |t|
    t.string   "merged_first_name"
    t.string   "merged_last_name"
    t.string   "merged_club_or_hometown"
    t.string   "merged_nationality"
    t.string   "merged_sex"
    t.date     "merged_birth_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "merge_runners_requests_runners", id: false, force: :cascade do |t|
    t.integer "runner_id",                null: false
    t.integer "merge_runners_request_id", null: false
  end

  create_table "organizers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", force: :cascade do |t|
    t.float    "length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "run_day_category_aggregates", force: :cascade do |t|
    t.integer  "category_id",   null: false
    t.integer  "run_day_id",    null: false
    t.integer  "mean_duration"
    t.integer  "runs_count"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "run_day_category_aggregates", ["category_id", "run_day_id"], name: "index_run_day_category_aggregates_on_category_id_and_run_day_id", using: :btree

  create_table "run_days", force: :cascade do |t|
    t.integer  "organizer_id"
    t.date     "date"
    t.string   "weather"
    t.integer  "route_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "run_days", ["organizer_id"], name: "index_run_days_on_organizer_id", using: :btree
  add_index "run_days", ["route_id"], name: "index_run_days_on_route_id", using: :btree

  create_table "runners", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birth_date"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "sex"
    t.string   "club_or_hometown"
    t.string   "nationality"
    t.integer  "runs_count",       default: 0
  end

  add_index "runners", ["club_or_hometown"], name: "index_runners_on_club_or_hometown", using: :btree
  add_index "runners", ["first_name"], name: "index_runners_on_first_name", using: :btree
  add_index "runners", ["last_name"], name: "index_runners_on_last_name", using: :btree
  add_index "runners", ["nationality"], name: "index_runners_on_nationality", using: :btree
  add_index "runners", ["runs_count"], name: "index_runners_on_runs_count", using: :btree
  add_index "runners", ["sex"], name: "index_runners_on_sex", using: :btree

  create_table "runs", force: :cascade do |t|
    t.integer  "runner_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "category_id"
    t.integer  "duration",    limit: 8
    t.integer  "run_day_id"
  end

  add_index "runs", ["category_id"], name: "index_runs_on_category_id", using: :btree
  add_index "runs", ["run_day_id"], name: "index_runs_on_run_day_id", using: :btree
  add_index "runs", ["runner_id"], name: "index_runs_on_runner_id", using: :btree

  add_foreign_key "run_days", "organizers"
  add_foreign_key "run_days", "routes"
  add_foreign_key "runs", "categories"
  add_foreign_key "runs", "run_days"
  add_foreign_key "runs", "runners"
end
