config = require "lapis.config"

hash = (...) ->
  {item, true for item in *{...}}

config "production", ->
  port 80
  secret os.getenv("SESSION_SECRET")
  session_name os.getenv("SESSION_NAME")
  code_cache "on"
  num_workers 4
  postgres ->
    host os.getenv("POSTGRES_HOST") or "postgres"
    user os.getenv("POSTGRES_USER") or "postgres"
    password os.getenv("POSTGRES_PASSWORD") or "" -- using a blank password is untested
    database os.getenv("POSTGRES_DB") or "postgres"

  -- custom configuration options
  app_name os.getenv("APP_NAME")
  username_blacklist hash "admin", "administrator", "me", "new", "list"
  bcrypt_digest_rounds os.getenv("BCRYPT_DISGEST_ROUNDS") or 9
  recaptcha_secret os.getenv("RECAPTCHA_SECRET")
  console os.getenv("ENABLE_CONSOLE") or false
