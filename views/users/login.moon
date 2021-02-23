import Widget from require "lapis.html"

class UsersLogin extends Widget
  content: =>
    form {
      action: @url_for "users_login", nil, redirect: @params.redirect
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      input type: "text", name: "name", placeholder: "Username", autocomplete: "username"
      input type: "password", name: "password", placeholder: "Password"
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit", value: "Login"
