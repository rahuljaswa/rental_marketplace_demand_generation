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

ActiveRecord::Schema.define(version: 20170110192356) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.string   "title",                           null: false
    t.boolean  "active",           default: true
    t.text     "description"
    t.float    "security_deposit",                null: false
    t.float    "price",                           null: false
    t.string   "image_urls",       default: [],                array: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",                            null: false
    t.string   "image_url",                       null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.float    "adwords_max_average_cpc"
    t.float    "adwords_max_average_position"
    t.float    "adwords_max_impressions_per_day"
    t.float    "adwords_max_click_through_rate"
    t.float    "adwords_max_clicks_per_day"
  end

  create_table "tags_products", id: false, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "product_id"
    t.index ["product_id"], name: "index_tags_products_on_product_id", using: :btree
    t.index ["tag_id"], name: "index_tags_products_on_tag_id", using: :btree
  end

end
