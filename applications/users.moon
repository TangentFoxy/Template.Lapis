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

validate_functions.unique_user = (input) ->
  return not Users\find name: input
validate_functions.not_one_of = (input, hash_table) ->
  return not hash_table[input]
validate_functions.max_repetition = (input, max) ->
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

  [new: "/new"]: respond_to {
    GET: =>
      if @user
        @session.message = "You are already logged in."
        return redirect_to: @params.redirect or @url_for "users_me"
      @csrf_token = csrf.generate_token(@)
      render: "users.new"
    POST: =>
      unless csrf.validate_token(@)
        @session.message = "Invalid CSRF token, please try again."
        return redirect_to: @params.redirect or @url_for "users_new"
      if config.recaptcha_secret and config.recaptcha_secret\len! > 1
        response = decode http.simple "https://www.google.com/recaptcha/api/siteverify", {
          secret: config.recaptcha_secret
          response: @params["g-recaptcha-response"]
        }
        unless response.success
          @session.message = "You failed the reCAPTCHA challenge, please try again."
          return redirect_to: @params.redirect or @url_for "users_new"
      if errors = validate @params, {
        { "name", exists: true, max_length: 255, matches_pattern: "%S+", unique_user: true, not_one_of: {config.username_blacklist} }
        { "password", exists: true, min_length: 12, max_repetition: 6 }
        { "email", min_length: 3, max_length: 255, matches_pattern: Users.email_pattern, optional: true }
      }
        @session.message = table.concat errors, ", "
        return redirect_to: @params.redirect or @url_for "users_new"

      bcrypt_digest = bcrypt.digest @params.password, config.bcrypt_digest_rounds
      user, err = Users\create {
        name: trim @params.name
        email: if @params.email and #@params.email > 0
          trim @params.email
        :bcrypt_digest
        admin: not Users\find admin: true
      }
      unless user
        @session.message = err
        return redirect_to: @url_for "users_new", nil, redirect: @params.redirect

      @session.id = user.id
      @session.message = "Account created. Welcome, #{user.name}!"
      return redirect_to: @params.redirect or @url_for "users_me"
  }

  [login: "/login"]: respond_to {
    GET: =>
      if @user
        @session.message = "You are already logged in."
        redirect_to: @params.redirect or @url_for "users_me"
      @csrf_token = csrf.generate_token(@)
      return render: "users.login"
    POST: =>
      unless csrf.validate_token(@)
        @session.message = "Invalid CSRF token, please try again."
        return redirect_to: @url_for "users_login", nil, redirect: @params.redirect
      if user = Users\find name: trim @params.name
        if bcrypt.verify @params.password, user.bcrypt_digest
          @session.id = user.id
          @session.message = "You have been logged in."
          return redirect_to: @params.redirect or @url_for "index"

      @session.message = "Incorrect credentials, please try again."
      return redirect_to: @url_for "users_login", nil, redirect: @params.redirect
  }

  [me: "/me"]: respond_to {
    GET: =>
      unless @user
        @session.message = "You are not logged in."
        return redirect_to: @url_for "users_login", nil, redirect: @params.redirect
      @csrf_token = csrf.generate_token(@)
      return render: "users.me"
    POST: =>
      unless csrf.validate_token(@)
        @session.message = "Invalid CSRF token, please try again."
        return redirect_to: @url_for "users_me", nil, redirect: @params.redirect
      if errors = validate @params, {
        { "name", exists: true, max_length: 255, unique_user: true, not_one_of: config.username_blacklist, optional: true }
        { "password", exists: true, min_length: 12, max_repetition: 6, optional: true }
        { "email", min_length: 3, max_length: 255, matches_pattern: Users.email_pattern, optional: true }
      }
        @session.message = table.concat errors, ", "
        return redirect_to: @url_for "users_new", nil, redirect: @params.redirect

      if @params.password
        bcrypt_digest = bcrypt.digest @params.password, config.bcrypt_digest_rounds
      @user\update {
        name: if @params.name and #@params.name > 0
          trim @params.name
        email: if @params.email and #@params.email > 0
          trim @params.email
        :bcrypt_digest
      }

      @session.id = user.id
      @session.message = "Account updated!"
      return redirect_to: @params.redirect or @url_for "users_me"
  }
