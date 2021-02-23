# Template.Lapis

- Users model, bcrypt-backed authentication, reCAPTCHA protection on signup.
- NGINX conf ready for in-docker use & proxied HTTP requests from within Lapis.
- Lapis Console, lua-cjson

Authenticated users are identified by session `id` in their signed cookie.
Displaying a message to users is supported by setting `message` in the session.
