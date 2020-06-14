config = require "lapis.config"

config "production", ->
  session_name os.getenv("SESSION_SECRET") or "secret"
  postgres ->
    host os.getenv("POSTGRES_HOST") or "postgres"
    user os.getenv("POSTGRES_USER") or "postgres"
    password os.getenv("POSTGRES_PASSWORD") or "" -- untested
    database os.getenv("POSTGRES_DB") or "postgres"
  port 80
  num_workers 4

  digest_rounds 9
  console os.getenv("ENABLE_CONSOLE") or false
