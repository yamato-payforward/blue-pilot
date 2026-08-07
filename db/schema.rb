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

ActiveRecord::Schema[8.1].define(version: 2026_08_07_140007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "candles", force: :cascade do |t|
    t.decimal "close", precision: 20, scale: 8, null: false
    t.datetime "created_at", null: false
    t.decimal "high", precision: 20, scale: 8, null: false
    t.bigint "instrument_id", null: false
    t.decimal "low", precision: 20, scale: 8, null: false
    t.decimal "open", precision: 20, scale: 8, null: false
    t.datetime "open_time", null: false
    t.decimal "quote_volume", precision: 30, scale: 8
    t.decimal "taker_buy_base_volume", precision: 30, scale: 8
    t.decimal "taker_buy_quote_volume", precision: 30, scale: 8
    t.string "timeframe", null: false
    t.integer "trades_count"
    t.datetime "updated_at", null: false
    t.decimal "volume", precision: 30, scale: 8, null: false
    t.index ["instrument_id", "timeframe", "open_time"], name: "index_candles_on_instrument_id_and_timeframe_and_open_time", unique: true
    t.index ["instrument_id"], name: "index_candles_on_instrument_id"
  end

  create_table "fear_greed_indices", force: :cascade do |t|
    t.string "classification"
    t.datetime "created_at", null: false
    t.date "recorded_on", null: false
    t.datetime "updated_at", null: false
    t.integer "value", null: false
    t.index ["recorded_on"], name: "index_fear_greed_indices_on_recorded_on", unique: true
  end

  create_table "funding_rates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "funding_rate", precision: 20, scale: 10, null: false
    t.datetime "funding_time", null: false
    t.bigint "instrument_id", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id", "funding_time"], name: "index_funding_rates_on_instrument_id_and_funding_time", unique: true
    t.index ["instrument_id"], name: "index_funding_rates_on_instrument_id"
  end

  create_table "instruments", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "base", null: false
    t.datetime "created_at", null: false
    t.string "exchange", null: false
    t.string "market_type", default: "perpetual", null: false
    t.string "quote", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange", "base", "quote", "market_type"], name: "index_instruments_on_exchange_and_pair", unique: true
  end

  create_table "long_short_ratios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "instrument_id", null: false
    t.decimal "long_value", precision: 20, scale: 8, null: false
    t.decimal "ratio", precision: 20, scale: 8, null: false
    t.string "ratio_type", null: false
    t.datetime "recorded_at", null: false
    t.decimal "short_value", precision: 20, scale: 8, null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id", "ratio_type", "recorded_at"], name: "index_long_short_ratios_on_instrument_type_and_time", unique: true
    t.index ["instrument_id"], name: "index_long_short_ratios_on_instrument_id"
  end

  create_table "open_interests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "instrument_id", null: false
    t.decimal "open_interest", precision: 30, scale: 8, null: false
    t.decimal "open_interest_value", precision: 30, scale: 8
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id", "recorded_at"], name: "index_open_interests_on_instrument_id_and_recorded_at", unique: true
    t.index ["instrument_id"], name: "index_open_interests_on_instrument_id"
  end

  create_table "premium_indices", force: :cascade do |t|
    t.decimal "basis_pct", precision: 20, scale: 10, null: false
    t.datetime "created_at", null: false
    t.decimal "index_price", precision: 20, scale: 8, null: false
    t.bigint "instrument_id", null: false
    t.decimal "mark_price", precision: 20, scale: 8, null: false
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id", "recorded_at"], name: "index_premium_indices_on_instrument_id_and_recorded_at", unique: true
    t.index ["instrument_id"], name: "index_premium_indices_on_instrument_id"
  end

  add_foreign_key "candles", "instruments"
  add_foreign_key "funding_rates", "instruments"
  add_foreign_key "long_short_ratios", "instruments"
  add_foreign_key "open_interests", "instruments"
  add_foreign_key "premium_indices", "instruments"
end
