# CORS

In Rails api app cors file is already created use `gem "rack-cors"` for added security on before loading page.

~~~
# edit secrets.yml
EDITOR="vi --wait" rails credentials:edit
EDITOR="vi" rails credentials:edit
~~~

~~~
# secrets.yml

development:
  allowed_origins:
   - http://localhost:3000
   - http://runbhumi:3000

test:
  allowed_origins:
   - https://example.com

production:
  allowed_origins:
   - https://example.com

# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: d8ce
~~~



Update secret origins in CORS

~~~
# services/back/user-api/config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.application.credentials[Rails.env.to_sym][:allowed_origins]

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
~~~
