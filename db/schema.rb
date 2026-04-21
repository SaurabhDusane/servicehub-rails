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

ActiveRecord::Schema[7.1].define(version: 2025_01_01_000016) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "payload", default: {}, null: false
    t.inet "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "availability_exceptions", force: :cascade do |t|
    t.bigint "provider_profile_id", null: false
    t.date "date", null: false
    t.time "start_time"
    t.time "end_time"
    t.integer "exception_type", default: 0, null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id", "date"], name: "index_availability_exceptions_on_provider_profile_id_and_date"
    t.index ["provider_profile_id"], name: "index_availability_exceptions_on_provider_profile_id"
  end

  create_table "availability_windows", force: :cascade do |t|
    t.bigint "provider_profile_id", null: false
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id", "day_of_week"], name: "idx_on_provider_profile_id_day_of_week_acf3c2fb32"
    t.index ["provider_profile_id"], name: "index_availability_windows_on_provider_profile_id"
    t.check_constraint "day_of_week >= 0 AND day_of_week <= 6", name: "day_of_week_range"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "provider_profile_id", null: false
    t.bigint "service_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "timezone", default: "UTC", null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "deposit_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.text "notes"
    t.text "cancellation_reason"
    t.datetime "cancelled_at"
    t.bigint "cancelled_by_id"
    t.datetime "confirmed_at"
    t.datetime "completed_at"
    t.datetime "reminder_sent_at"
    t.datetime "review_request_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cancelled_by_id"], name: "index_bookings_on_cancelled_by_id"
    t.index ["customer_id", "start_time"], name: "index_bookings_on_customer_id_and_start_time"
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["payment_status"], name: "index_bookings_on_payment_status"
    t.index ["provider_profile_id", "start_time"], name: "index_bookings_on_provider_profile_id_and_start_time"
    t.index ["provider_profile_id"], name: "index_bookings_on_provider_profile_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.index ["start_time"], name: "index_bookings_on_start_time"
    t.index ["status"], name: "index_bookings_on_status"
    t.check_constraint "end_time > start_time", name: "booking_time_order"
    t.exclusion_constraint "provider_profile_id WITH =, tsrange(start_time, end_time) WITH &&", where: "status = ANY (ARRAY[0, 1])", using: :gist, name: "no_overlapping_bookings"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "provider_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_favorites_on_provider_profile_id"
    t.index ["user_id", "provider_profile_id"], name: "index_favorites_on_user_id_and_provider_profile_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "kind", null: false
    t.string "title", null: false
    t.text "body"
    t.string "url"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_charge_id"
    t.integer "amount_cents", default: 0, null: false
    t.integer "refunded_amount_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.integer "status", default: 0, null: false
    t.integer "kind", default: 0, null: false
    t.string "receipt_url"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name", null: false
    t.string "slug", null: false
    t.text "bio"
    t.string "category", null: false
    t.string "location"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "service_radius_km", default: 25
    t.string "response_time", default: "within_24h"
    t.text "cancellation_policy"
    t.integer "cancellation_cutoff_hours", default: 24
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0", null: false
    t.integer "total_reviews", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.boolean "onboarding_completed", default: false, null: false
    t.string "website"
    t.string "instagram"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["average_rating"], name: "index_provider_profiles_on_average_rating"
    t.index ["category"], name: "index_provider_profiles_on_category"
    t.index ["slug"], name: "index_provider_profiles_on_slug", unique: true
    t.index ["status"], name: "index_provider_profiles_on_status"
    t.index ["user_id"], name: "index_provider_profiles_on_user_id", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "reporter_id", null: false
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.string "reason", null: false
    t.text "notes"
    t.integer "status", default: 0, null: false
    t.bigint "resolved_by_id"
    t.datetime "resolved_at"
    t.text "resolution_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["resolved_by_id"], name: "index_reports_on_resolved_by_id"
    t.index ["status"], name: "index_reports_on_status"
    t.index ["target_type", "target_id"], name: "index_reports_on_target_type_and_target_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "provider_profile_id", null: false
    t.integer "rating", null: false
    t.text "body"
    t.boolean "hidden", default: false, null: false
    t.text "moderation_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id", unique: true
    t.index ["customer_id"], name: "index_reviews_on_customer_id"
    t.index ["provider_profile_id"], name: "index_reviews_on_provider_profile_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "rating_range"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "provider_profile_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "category", null: false
    t.integer "duration_minutes", default: 60, null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "deposit_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.boolean "instant_booking", default: false, null: false
    t.boolean "requires_approval", default: true, null: false
    t.boolean "active", default: true, null: false
    t.integer "buffer_minutes", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_services_on_active"
    t.index ["category"], name: "index_services_on_category"
    t.index ["provider_profile_id", "active"], name: "index_services_on_provider_profile_id_and_active"
    t.index ["provider_profile_id"], name: "index_services_on_provider_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "timezone", default: "UTC", null: false
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "availability_exceptions", "provider_profiles"
  add_foreign_key "availability_windows", "provider_profiles"
  add_foreign_key "bookings", "provider_profiles"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users", column: "cancelled_by_id"
  add_foreign_key "bookings", "users", column: "customer_id"
  add_foreign_key "favorites", "provider_profiles"
  add_foreign_key "favorites", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reports", "users", column: "resolved_by_id"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "provider_profiles"
  add_foreign_key "reviews", "users", column: "customer_id"
  add_foreign_key "services", "provider_profiles"
end
