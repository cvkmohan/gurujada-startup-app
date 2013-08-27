# Rails 4.0 App with Mongoid, Devise, CanCan, OmniAuth and Twitter Bootstrap (TDD ready)
---

You can use this project as a starting point for a Rails web application. It requires Rails 4 uses Mongoid as database, Devise/OmniAuth for user management and authentication, CanCan for user access control, and Twitter Bootstrap 3.0 for CSS styling.


## How to use

* Install rails 4: `gem install rails`
* Generate new rails app from template: 

```
rails new myapp --skip-bundle -m https://raw.github.com/krushi123/gurujada-startup-app/master/template.rb
```
* `cd myapp`
* Edit `db/seed.rb` to customimze admin user settings then run `rake db:seed` to create admin user
* Edit `config/initializers/devise.rb` to customize your omniauth providers:

```ruby
config.omniauth :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope: 'email,user_birthday,read_stream'
config.omniauth :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
```

