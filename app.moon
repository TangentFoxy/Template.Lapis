lapis = require "lapis"
config = require("lapis.config").get!

import Users from require "models"

class MainApplication extends lapis.Application
  @include "applications.users"

  @before_filter =>
    if @session.message
      @message = @session.message
      @session.message = nil
    if @session.id
      @user = Users\find id: @session.id

  layout: "layout"

  [console: "/console"]: =>
    if @user and @user.admin
      if config and config.console and config.console\lower! == "true"
        return require("lapis.console").make(env: "all")(@)
    return status: 401, render: "unauthorized"

  [index: "/"]: => return "To be built."
