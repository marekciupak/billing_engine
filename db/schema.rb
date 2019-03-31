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

ActiveRecord::Schema.define(version: 2019_03_31_203719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "line1", null: false
    t.string "line2", null: false
    t.string "zip_code", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subscription_id", null: false
    t.index ["subscription_id"], name: "index_addresses_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "plan", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "expires_on", null: false
    t.string "customer_id", null: false
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
    t.index ["expires_on"], name: "index_subscriptions_on_expires_on"
    t.index ["token"], name: "index_subscriptions_on_token", unique: true
  end

  add_foreign_key "addresses", "subscriptions"
end
