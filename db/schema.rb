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

ActiveRecord::Schema.define(version: 20180919161917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "broadband_types", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "broadbands", force: :cascade do |t|
    t.string "anchorname"
    t.string "address"
    t.string "bldgnbr"
    t.string "predir"
    t.string "streetname"
    t.string "streettype"
    t.string "suffdir"
    t.string "city"
    t.string "state_code"
    t.string "zip5"
    t.string "latitude"
    t.string "longitude"
    t.string "publicwifi"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner_file_name"
    t.string "banner_content_type"
    t.integer "banner_file_size"
    t.datetime "banner_updated_at"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.bigint "broadband_type_id"
    t.string "services"
    t.string "notes"
    t.string "manager_name"
    t.string "user_id"
    t.string "detail"
    t.integer "rating", default: 5
    t.string "access_code"
    t.string "email"
    t.string "phone_no"
    t.string "password"
    t.boolean "is_approved"
    t.index ["broadband_type_id"], name: "index_broadbands_on_broadband_type_id"
  end

  create_table "faqs", force: :cascade do |t|
    t.bigint "broadband_id"
    t.string "question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["broadband_id"], name: "index_faqs_on_broadband_id"
  end

  create_table "opening_hours", force: :cascade do |t|
    t.bigint "broadband_id"
    t.integer "day", null: false
    t.time "from"
    t.time "to"
    t.boolean "closed", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["broadband_id"], name: "index_opening_hours_on_broadband_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "manager_name"
    t.string "phone_no"
    t.string "address"
    t.string "password"
    t.string "user_id"
    t.boolean "is_approved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_code"
    t.string "summary"
    t.string "streetname"
    t.string "city"
    t.string "state_code"
    t.string "zip5"
    t.bigint "broadband_type_id"
    t.index ["broadband_type_id"], name: "index_organizations_on_broadband_type_id"
  end

  create_table "points", force: :cascade do |t|
    t.bigint "broadband_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["broadband_id"], name: "index_points_on_broadband_id"
    t.index ["user_id"], name: "index_points_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "broadband_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rating", default: 5
    t.index ["broadband_id"], name: "index_reviews_on_broadband_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "user_broadbands", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "broadband_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["broadband_id"], name: "index_user_broadbands_on_broadband_id"
    t.index ["user_id"], name: "index_user_broadbands_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roles", default: [], array: true
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "auth_token"
    t.string "uid"
    t.string "provider"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.string "profile_picture"
    t.string "phone_no"
    t.string "address"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "broadbands", "broadband_types"
  add_foreign_key "opening_hours", "broadbands"
  add_foreign_key "organizations", "broadband_types"
  add_foreign_key "user_broadbands", "broadbands"
  add_foreign_key "user_broadbands", "users"
end
