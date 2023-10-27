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

ActiveRecord::Schema[7.0].define(version: 2023_10_27_145740) do
  create_table "academic_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "current_cgpa"
    t.string "rollno"
    t.integer "yop"
    t.bigint "branch_id", null: false
    t.string "section"
    t.boolean "backlogs"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_academic_details_on_branch_id"
    t.index ["user_id"], name: "index_academic_details_on_user_id"
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

  create_table "branches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.string "abbr"
    t.string "des"
    t.bigint "college_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_id"], name: "index_branches_on_college_id"
  end

  create_table "campus_selections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recruitment_id", null: false
    t.integer "ctc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recruitment_id"], name: "index_campus_selections_on_recruitment_id"
    t.index ["user_id"], name: "index_campus_selections_on_user_id"
  end

  create_table "colleges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "college_name"
    t.string "college_code"
    t.string "abbr"
    t.string "address"
    t.string "contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "company_name"
    t.string "address"
    t.string "contact"
    t.string "passkey"
    t.string "des"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email"
    t.string "u_email"
    t.string "phone"
    t.string "alt_phone"
    t.string "socials"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contact_details_on_user_id"
  end

  create_table "internship_documents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "document_link"
    t.boolean "is_verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_internship_documents_on_user_id"
  end

  create_table "internships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "company_name"
    t.string "role_title"
    t.integer "stipend"
    t.string "start_date"
    t.string "end_date"
    t.boolean "noc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "turned_in"
    t.index ["user_id"], name: "index_internships_on_user_id"
  end

  create_table "names", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first"
    t.string "middle"
    t.string "last"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_names_on_user_id"
  end

  create_table "offcampus_selections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "ctc"
    t.string "company_name"
    t.string "job_type"
    t.string "location"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_offcampus_selections_on_user_id"
  end

  create_table "personal_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.binary "photo"
    t.string "gender"
    t.string "dob"
    t.string "mother_name"
    t.string "father_name"
    t.string "nationality"
    t.string "passport"
    t.string "PAN"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_personal_details_on_user_id"
  end

  create_table "recruitment_updates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "recruitment_id", null: false
    t.string "title"
    t.string "description"
    t.string "start"
    t.string "end"
    t.string "link1"
    t.string "link2"
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recruitment_id"], name: "index_recruitment_updates_on_recruitment_id"
  end

  create_table "recruitments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "college_id", null: false
    t.bigint "company_id", null: false
    t.string "role"
    t.string "des"
    t.string "jd_link"
    t.string "ctc"
    t.string "last_date"
    t.string "eligibility"
    t.string "role_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.boolean "completed"
    t.index ["college_id"], name: "index_recruitments_on_college_id"
    t.index ["company_id"], name: "index_recruitments_on_company_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.string "usertype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "college_id", null: false
    t.index ["college_id"], name: "index_users_on_college_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "academic_details", "branches"
  add_foreign_key "academic_details", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "branches", "colleges"
  add_foreign_key "campus_selections", "recruitments"
  add_foreign_key "campus_selections", "users"
  add_foreign_key "contact_details", "users"
  add_foreign_key "internship_documents", "users"
  add_foreign_key "internships", "users"
  add_foreign_key "names", "users"
  add_foreign_key "offcampus_selections", "users"
  add_foreign_key "personal_details", "users"
  add_foreign_key "recruitment_updates", "recruitments"
  add_foreign_key "recruitments", "colleges"
  add_foreign_key "recruitments", "companies"
  add_foreign_key "users", "colleges"
end
