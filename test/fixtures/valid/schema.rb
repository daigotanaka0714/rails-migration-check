ActiveRecord::Schema.define(version: 20250101010101) do
  create_table "users", force: :cascade do |t|
    t.string "name"
  end
end
