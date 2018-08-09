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

ActiveRecord::Schema.define(version: 20160304162448) do

  create_table "agents", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customer_cards", force: true do |t|
    t.integer  "customer_id"
    t.text     "encrypted_card_number"
    t.text     "encrypted_ccv"
    t.text     "encrypted_exp_month"
    t.text     "encrypted_exp_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "card_name"
  end

  create_table "customers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name",                     null: false
    t.string   "email",                         null: false
    t.string   "address1",                      null: false
    t.string   "address2"
    t.string   "city",                          null: false
    t.string   "state",                         null: false
    t.string   "zip",                           null: false
    t.string   "stripe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.integer  "shopify_customer_id", limit: 8
  end

  add_index "customers", ["stripe_id"], name: "index_customers_on_stripe_id", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "distributor_orders", force: true do |t|
    t.integer  "distributor_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "distributors", force: true do |t|
    t.string   "email",                                  null: false
    t.string   "password_digest",                        null: false
    t.boolean  "require_password_reset", default: true
    t.string   "company_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone",                                  null: false
    t.string   "address1",                               null: false
    t.string   "address2"
    t.string   "city",                                   null: false
    t.string   "state",                                  null: false
    t.string   "zip",                                    null: false
    t.boolean  "approved",               default: false, null: false
    t.integer  "price",                  default: 5995,  null: false
    t.string   "stripe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
  end

  create_table "domain_distributors", force: true do |t|
    t.string   "name"
    t.string   "company_name"
    t.string   "email"
    t.float    "percentage"
    t.string   "phone"
    t.text     "address"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain"
  end

  create_table "forums", force: true do |t|
    t.string   "subject"
    t.text     "content"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.string   "state"
    t.string   "name"
    t.text     "address"
    t.string   "domain_name"
  end

  create_table "order_deliveries", force: true do |t|
    t.integer  "order_id"
    t.date     "delivered_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: true do |t|
    t.integer  "order_id",               null: false
    t.integer  "product_id",             null: false
    t.integer  "quantity",   default: 1, null: false
    t.integer  "price",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "tax"
    t.integer  "s_h_cost"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "orderer_id",                                       null: false
    t.string   "orderer_type",                                     null: false
    t.string   "destription"
    t.string   "stripe_id"
    t.datetime "refunded_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "host"
    t.integer  "shipment_id"
    t.integer  "shopify_order_id",       limit: 8
    t.integer  "recurrent_order_id"
    t.string   "order_type"
    t.date     "first_delivery_date"
    t.date     "next_delivery_date"
    t.date     "last_delivery_date"
    t.boolean  "cancelled",                        default: false
    t.integer  "parent_order_id"
    t.float    "shipping_price"
    t.float    "process_handling_price"
    t.integer  "agent_id"
    t.string   "eh"
    t.boolean  "version_2_order",                  default: false
    t.datetime "cancelled_at"
  end

  add_index "orders", ["orderer_id", "orderer_type"], name: "index_orders_on_orderer_id_and_orderer_type", using: :btree
  add_index "orders", ["shipment_id"], name: "index_orders_on_shipment_id", using: :btree
  add_index "orders", ["stripe_id"], name: "index_orders_on_stripe_id", unique: true, using: :btree

  create_table "product_prices", force: true do |t|
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "recurrent_price"
  end

  create_table "products", force: true do |t|
    t.string   "product_code",    null: false
    t.integer  "price",           null: false
    t.string   "description",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "weight"
    t.string   "sku"
    t.string   "product_type"
    t.float    "recurrent_price"
  end

  create_table "reccurent_orders", force: true do |t|
    t.integer  "customer_id"
    t.integer  "order_id"
    t.datetime "start_date"
    t.datetime "next_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recurrent_products", force: true do |t|
    t.string   "product_name"
    t.string   "subscription_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipments", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
