import Widget from require "lapis.html"

class Unauthorized extends Widget
  content: =>
    @title = "401 - Unauthorized"
    p @title
