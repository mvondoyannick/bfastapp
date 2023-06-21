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

ActiveRecord::Schema[7.0].define(version: 2023_06_21_034645) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "pushname"
    t.string "phone"
    t.string "ip"
    t.string "sexe"
    t.string "age"
    t.string "tension_gauche"
    t.string "tension_droit"
    t.string "quartier"
    t.string "link"
    t.string "steps"
    t.string "real_name"
    t.string "code"
    t.string "diastole_droit"
    t.string "diastole_gauche"
    t.string "poul_droit"
    t.string "poul_gauche"
    t.string "linked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "question_tension"
    t.string "rappel"
    t.string "rappel_day"
    t.datetime "date_rappel"
    t.string "photo"
    t.string "photo_type"
    t.boolean "is_cropped"
    t.string "cropped"
    t.string "poids"
    t.string "taille"
    t.string "lang"
  end

  create_table "erreurs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "description"
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_erreurs_on_customer_id"
  end

  create_table "parametres", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "tension_droite"
    t.string "tension_gauche"
    t.string "quartier"
    t.string "steps"
    t.string "code"
    t.string "diastole_droit"
    t.string "diastole_gauche"
    t.string "poul_droit"
    t.string "poul_gauche"
    t.string "linked"
    t.string "question_tension"
    t.string "rappel"
    t.string "rappel_day"
    t.string "date_rappel"
    t.string "photo"
    t.string "photo_type"
    t.boolean "is_cropped"
    t.string "cropped"
    t.string "poids"
    t.string "taille"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "tension_droite"
    t.string "tension_gauche"
    t.string "quartier"
    t.string "steps"
    t.string "code"
    t.string "diastole_droit"
    t.string "diastole_gauche"
    t.string "poul_droit"
    t.string "poul_gauche"
    t.string "linked"
    t.string "question_tension"
    t.string "rappel"
    t.string "rappel_day"
    t.string "date_rappel"
    t.string "photo"
    t.string "photo_type"
    t.boolean "is_cropped"
    t.string "cropped"
    t.string "poids"
    t.string "taille"
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "lang"
    t.index ["customer_id"], name: "index_settings_on_customer_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "erreurs", "customers"
  add_foreign_key "settings", "customers"
end
