import Model from require "lapis.db.model"
config = require("lapis.config").get!

class Users extends Model
  @constraints: {
    bcrypt_digest: (value) =>
      -- password digest cannot be fully checked here
      if not value or value\len! < 1
        return "A password digest must exist."

    name: (value) =>
      if not value or value\len! < 1
        return "Users must have a name."

      if value\len! > 255
        return "User names must be 255 or fewer bytes in length."

      if value\find "%s"
        return "User names cannot contain spaces."

      if config.username_blacklist[value\lower!]
        return "That name is unavailable."

      if Users\find name: value\lower!
        return "That name is unavailable."

    email: (value) =>
      if value
        if value\len! > 255
          return "Email addresses must be 255 or fewer bytes in length."

        if value\find "%s"
          return "Email addresses cannot contain spaces."

        if not value\match ".+@.+"
          return "Email addresses must be valid."
  }
