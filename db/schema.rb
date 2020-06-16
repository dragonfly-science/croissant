# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_11_040052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "consultation_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "consultation_id"
    t.integer "role", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_id"], name: "index_consultation_users_on_consultation_id"
    t.index ["user_id"], name: "index_consultation_users_on_user_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "consultation_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.string "state"
  end

  create_table "submission_tags", force: :cascade do |t|
    t.bigint "submission_id"
    t.bigint "tag_id"
    t.integer "start_char"
    t.integer "end_char"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "text"
    t.bigint "tagger_id"
    t.index ["submission_id"], name: "index_submission_tags_on_submission_id"
    t.index ["tag_id"], name: "index_submission_tags_on_tag_id"
    t.index ["tagger_id"], name: "index_submission_tags_on_tagger_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "text"
    t.text "description"
    t.string "state"
    t.datetime "submitted_at"
    t.string "channel"
    t.string "source"
    t.string "name"
    t.string "email_address"
    t.string "address"
    t.string "phone_number"
    t.string "query_type"
    t.string "anonymise"
    t.string "submitter_type"
    t.boolean "exemplar"
    t.boolean "maori_perspective"
    t.boolean "pacific_perspective"
    t.boolean "high_impact_stakeholder"
    t.boolean "high_relevance_stakeholder"
    t.string "age_bracket"
    t.string "ethnicity"
    t.string "gender"
    t.string "file_hash"
    t.bigint "survey_id"
    t.index ["consultation_id"], name: "index_submissions_on_consultation_id"
    t.index ["survey_id"], name: "index_submissions_on_survey_id"
  end

  create_table "survey_answers", force: :cascade do |t|
    t.bigint "survey_question_id", null: false
    t.bigint "submission_id", null: false
    t.text "answer", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_survey_answers_on_submission_id"
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
  end

  create_table "survey_imports", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_id"], name: "index_survey_imports_on_consultation_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.text "question", null: false
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_id"], name: "index_surveys_on_consultation_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "taxonomy_id", null: false
    t.string "name"
    t.bigint "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.string "full_number"
    t.string "description"
    t.index ["parent_id"], name: "index_tags_on_parent_id"
    t.index ["taxonomy_id"], name: "index_tags_on_taxonomy_id"
  end

  create_table "taxonomies", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_id"], name: "index_taxonomies_on_consultation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0
    t.string "state"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.datetime "created_at"
    t.json "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "submission_tags", "users", column: "tagger_id"
  add_foreign_key "submissions", "consultations"
  add_foreign_key "submissions", "surveys"
  add_foreign_key "survey_answers", "submissions"
  add_foreign_key "survey_answers", "survey_questions"
  add_foreign_key "survey_imports", "consultations"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "surveys", "consultations"
  add_foreign_key "tags", "taxonomies"
  add_foreign_key "taxonomies", "consultations"
end
