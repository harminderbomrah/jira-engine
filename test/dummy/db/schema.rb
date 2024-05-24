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

ActiveRecord::Schema[7.1].define(version: 2024_05_06_080838) do
  create_table "jira_code_giant_users", force: :cascade do |t|
    t.string "graphql_id"
    t.string "name"
    t.string "username"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graphql_id"], name: "index_jira_code_giant_users_on_graphql_id"
  end

  create_table "jira_comments", force: :cascade do |t|
    t.integer "jira_issue_id"
    t.string "author"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jira_field_mappings", force: :cascade do |t|
    t.json "mapping", default: {}, null: false
    t.integer "jira_project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jira_project_id"], name: "index_jira_field_mappings_on_jira_project_id"
  end

  create_table "jira_histories", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at"
    t.json "items", default: {}, null: false
    t.integer "jira_issue_id", null: false
    t.index ["jira_issue_id"], name: "index_jira_histories_on_jira_issue_id"
  end

  create_table "jira_issues", force: :cascade do |t|
    t.string "key"
    t.string "summary"
    t.text "description"
    t.string "status"
    t.string "creator_display_name"
    t.string "reporter_display_name"
    t.datetime "jira_created_at"
    t.datetime "jira_updated_at"
    t.string "jira_project_id2"
    t.string "priority"
    t.string "issue_type"
    t.integer "jira_issue_id"
    t.integer "jira_project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "jira_user_id"
    t.integer "code_giant_user_id"
    t.integer "code_giant_task_id"
    t.integer "estimated_time"
    t.integer "actual_time"
    t.datetime "due_date"
    t.index ["code_giant_task_id"], name: "index_jira_issues_on_code_giant_task_id"
    t.index ["jira_issue_id"], name: "index_jira_issues_on_jira_issue_id", unique: true
    t.index ["jira_project_id"], name: "index_jira_issues_on_jira_project_id"
  end

  create_table "jira_jira_users", force: :cascade do |t|
    t.string "account_id"
    t.string "display_name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jira_projects", force: :cascade do |t|
    t.string "project_id"
    t.string "project_key"
    t.string "name"
    t.string "url"
    t.integer "jira_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "code_giant_project_id"
    t.string "prefix"
    t.string "codegiant_title"
    t.index ["code_giant_project_id"], name: "index_jira_projects_on_code_giant_project_id"
    t.index ["jira_user_id"], name: "index_jira_projects_on_jira_user_id"
  end

  create_table "jira_users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "jira_uid"
    t.string "jira_access_token"
    t.string "jira_refresh_token"
    t.datetime "token_expires_at"
    t.string "jira_site_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jira_site_id"
  end

  create_table "project_priorities", force: :cascade do |t|
    t.integer "project_id"
    t.integer "priority_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_statuses", force: :cascade do |t|
    t.integer "project_id"
    t.integer "status_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_types", force: :cascade do |t|
    t.integer "project_id"
    t.integer "type_id"
    t.string "title"
    t.string "color"
    t.boolean "complete_trigger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "jira_comments", "jira_issues"
  add_foreign_key "jira_field_mappings", "jira_projects"
  add_foreign_key "jira_histories", "jira_issues"
  add_foreign_key "jira_issues", "jira_projects"
  add_foreign_key "jira_projects", "jira_users"
end
