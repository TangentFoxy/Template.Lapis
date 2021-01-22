lapis = require "lapis"
config = require("lapis.config").get!
http = require "lapis.nginx.http"
csrf = require "lapis.csrf"
bcrypt = require "bcrypt"

import Users from require "models"

import decode from require "cjson"
import respond_to from require "lapis.application"
import validate, validate_functions from require "lapis.validate"
import trim from require "lapis.util"

validate_functions.unique_user = (name) ->
  return not Users\find :name
validate_functions.not_one_of = (...) ->
  return not validate_functions.one_of(...)
validate_functions.max_repetitions = (input, max) ->
  repeats = {}
  for i = 1, #input
    character = input\sub i, i
    if repeats[character]
      repeats[character] += 1
    else
      repeats[character] = 1
  for _, count in pairs repeats
    if count >= max
      return false
  true

class UsersApplication extends lapis.Application
  @path: "/users"
  @name: "users_"

  views_prefix: "views.users"

  [new: "/new"]: respond_to {
    GET: =>
      if @user
        @session.message = "You are logged into an account already."
        redirect_to: @params.redirect or @url_for "users_me"
      @csrf_token = csrf.generate_token(@)
      render: true
    POST: =>
      unless csrf.validate_token(@)
        @session.message = "Invalid CSRF token, please try again."
        redirect_to: @params.redirect or @url_for "users_new"
      if config.recaptcha_secret and config.recaptcha_secret\len! > 1
        response = decode http.simple "https://www.google.com/recaptcha/api/siteverify", {
          secret: config.recaptcha_secret
          response: @params["g-recaptcha-response"]
        }
        unless response.success
          @session.message = "You failed the reCAPTCHA challenge, please try again."
          redirect_to: @params.redirect or @url_for "users_new"
      if errors = validate @params, {
        { "name", exists: true, unique_user: true, not_one_of: config.username_blacklist }
        { "password", exists: true, min_length: 12, max_repetitions: 6 }
      }
        @session.message = table.concat errors, ", "
        redirect_to: @params.redirect or @url_for "users_new"

      bcrypt_digest = bcrypt.digest @params.password, config.bcrypt_digest_rounds
      user = Users\create {
        name: trim @params.name
        email: if @params.email
          trim @params.email
        :bcrypt_digest
        admin: not Users\find admin: true
      }

      @session.id = user.id
      @session.message = "Account created. Welcome, #{user.name}!"
      redirect_to: @params.redirect or @url_for "users_me"
  }

  [users_me: "/me"]: => "TODO"
