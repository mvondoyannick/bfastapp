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

ActiveRecord::Schema[7.0].define(version: 2023_02_11_155315) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "buses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "immatriculation"
    t.string "chassis"
    t.string "brand"
    t.string "modele"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ville_id"
    t.index ["ville_id"], name: "index_buses_on_ville_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cusomers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "phone"
    t.string "sexe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_cusomers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_cusomers_on_reset_password_token", unique: true
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "second_name"
    t.string "phone"
    t.string "sexe"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp"
    t.boolean "active"
    t.boolean "verified"
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
  end

  create_table "distributions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.string "ville"
    t.bigint "entreprise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.text "token"
    t.index ["entreprise_id"], name: "index_distributions_on_entreprise_id"
  end

  create_table "drinks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entreprises", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "as_agence"
  end

  create_table "foods", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gaz_bottles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "modele"
    t.bigint "gaz_fournisseur_id"
    t.bigint "gaz_manufacturer_id"
    t.string "amount"
    t.text "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gaz_fournisseur_id"], name: "index_gaz_bottles_on_gaz_fournisseur_id"
    t.index ["gaz_manufacturer_id"], name: "index_gaz_bottles_on_gaz_manufacturer_id"
  end

  create_table "gaz_bottles_fournisseurs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "gaz_fournisseur_id", null: false
    t.bigint "gaz_bottle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gaz_bottle_id"], name: "index_gaz_bottles_fournisseurs_on_gaz_bottle_id"
    t.index ["gaz_fournisseur_id"], name: "index_gaz_bottles_fournisseurs_on_gaz_fournisseur_id"
  end

  create_table "gaz_fournisseurs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.bigint "ville_id"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ville_id"], name: "index_gaz_fournisseurs_on_ville_id"
  end

  create_table "gaz_manufacturers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "horaires", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "depart"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "departure"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "amount"
    t.bigint "category_id", null: false
    t.boolean "promotion"
    t.string "promotion_amount"
    t.datetime "promotion_begin"
    t.datetime "promotion_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "distribution_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["distribution_id"], name: "index_products_on_distribution_id"
  end

  create_table "reservations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "customer_name"
    t.string "customer_second_name"
    t.string "customer_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.string "depart"
    t.string "arrivee"
    t.string "date_depart"
    t.string "heure"
    t.string "customer_phone_payment"
    t.string "amount"
    t.boolean "paid"
    t.string "fee"
    t.bigint "customer_id"
    t.index ["customer_id"], name: "index_reservations_on_customer_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "travel_agences", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.boolean "active"
    t.bigint "travel_entreprise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ville_id"
    t.index ["travel_entreprise_id"], name: "index_travel_agences_on_travel_entreprise_id"
    t.index ["ville_id"], name: "index_travel_agences_on_ville_id"
  end

  create_table "travel_entreprises", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "token"
  end

  create_table "travel_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "amount"
    t.string "reference"
    t.string "tstatus"
    t.string "currency"
    t.string "operator"
    t.string "code"
    t.string "external_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "reservation_id"
    t.index ["reservation_id"], name: "index_travel_transactions_on_reservation_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "second_name"
    t.string "phone"
    t.string "sexe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.bigint "role_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "villes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.boolean "active"
    t.text "resume"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "buses", "villes"
  add_foreign_key "distributions", "entreprises"
  add_foreign_key "gaz_bottles", "gaz_fournisseurs"
  add_foreign_key "gaz_bottles", "gaz_manufacturers"
  add_foreign_key "gaz_bottles_fournisseurs", "gaz_bottles"
  add_foreign_key "gaz_bottles_fournisseurs", "gaz_fournisseurs"
  add_foreign_key "gaz_fournisseurs", "villes"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "distributions"
  add_foreign_key "reservations", "customers"
  add_foreign_key "travel_agences", "travel_entreprises"
  add_foreign_key "travel_agences", "villes"
  add_foreign_key "travel_transactions", "reservations"
  add_foreign_key "users", "roles"
end
