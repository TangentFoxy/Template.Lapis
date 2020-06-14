import create_table, types from require "lapis.db.schema"

{
  [1592100459]: =>
    create_table "users", {
      { "id", types.serial primary_key: true }
      { "name", types.varchar unique: true }
      { "email", types.varchar null: true }
      { "digest", types.varchar null: true }
      { "admin", types.boolean default: false }
    }
}
