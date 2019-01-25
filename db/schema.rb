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

ActiveRecord::Schema.define(version: 20190125040748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "domain_countries", force: :cascade do |t|
    t.string   "domain"
    t.string   "country"
    t.float    "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "domain_countries", ["domain", "country"], name: "index_domain_countries_on_domain_and_country", unique: true, using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "domain"
    t.integer  "num_external_links"
    t.integer  "num_internal_links"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
