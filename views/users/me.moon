import Widget from require "lapis.html"

class UsersMe extends Widget
  content: =>
    form {
      action: @url_for "users_me"
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      input type: "text", name: "name", value: @user.name, autocomplete: "username"
      input type: "password", name: "password", placeholder: "Password"
      input type: "email", name: "email", value: @user.email, placeholder: "Email"
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit", value: "Edit Account"
