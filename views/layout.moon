import Widget from require "lapis.html"
config = require("lapis.config").get!

class Layout extends Widget
  content: =>
    html_5 ->
      head ->
        title "#{@title and @title .. " - " or ""}#{config.app_name or ""}"
        meta charset: "utf-8"
        meta name: "viewport", content: "width=device-width, initial-scale=1"
        link rel: "stylesheet", href: "https://cdnjs.cloudflare.com/ajax/libs/mini.css/3.0.1/mini-default.min.css"
      body ->
        div class: "row", ->
          if @message
            div class: "col-sm-12", ->
              div class: "fluid warning card", ->
                p @message
          @content_for "inner"
