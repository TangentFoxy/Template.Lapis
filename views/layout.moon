import Widget from require "lapis.html"

class layout extends Widget
  content: =>
    html_5 ->
      head ->
        title(@title or "Ellis")
        meta charset: "utf-8"
      body ->
        @content_for "inner"
