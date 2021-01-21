import Widget from require "lapis.html"
config = require("lapis.config").get!

class layout extends Widget
  content: =>
    html_5 ->
      head ->
        title "#{@title and @title .. " - " or ""}#{config.app_name or ""}"
        meta charset: "utf-8"
      body ->
        @content_for "inner"
