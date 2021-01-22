import Widget from require "lapis.html"
config = require("lapis.config").get!

class UsersNew extends Widget
  content: =>
    form {
      action: @url_for "users_new", nil, redirect: @params.redirect
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      input type: "text", name: "name", placeholder: "Username", autocomplete: "username"
      input type: "password", name: "password", placeholder: "Password"
      input type: "email", name: "email", placeholder: "Email"
      input type: "hidden", name: "csrf_token", value: @csrf_token
      if config.recaptcha_secret
        div class: "g-recaptcha", "data-sitekey": config.recaptcha_secret
        script src: "https://www.google.com/recaptcha/api.js"
      input type: "submit", value: "Create Account"
