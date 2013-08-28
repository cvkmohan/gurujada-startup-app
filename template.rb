### Initial setup
remove_file 'config/database.yml'
remove_file 'app/assets/stylesheets/application.css'
remove_file 'app/controllers/application_controller.rb'
remove_file 'app/views/layouts/application.html.haml'
remove_file 'db/seeds.rb'
environment 'config.action_mailer.default_url_options = {host: "localhost:3000"}', env: 'development'


### Disable active record
gsub_file 'config/application.rb', "require 'rails/all'" do
<<-eos
#require 'rails/all'
require 'action_controller/railtie'
require 'action_mailer/railtie'
#require 'rails/test_unit/railtie'
require 'sprockets/railtie'
eos
end

gsub_file 'config/environments/development.rb', 'config.active_record', '#config.active_record'
gsub_file 'config/environments/production.rb', 'config.active_record', '#config.active_record'

### Gems
remove_file 'Gemfile'
create_file 'Gemfile'
add_source 'https://rubygems.org'

gem 'rails', '4.0.0'
gem 'puma'

gem "mongoid", github: "mongoid/mongoid"
gem "trackoid"
gem 'mongoid_taggable_with_context'

gem "devise", "~> 3.0.0" # Authentication
gem 'cancan' # Authorization via roles
gem "rolify",        :git => "git://github.com/EppO/rolify.git" # Role management
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-twitter"
gem "omniauth-google-oauth2"

gem 'haml-rails'
gem 'simple_form', :git => 'git://github.com/plataformatec/simple_form.git'
gem 'link_to_active_state'
gem 'kaminari'
gem 'draper'
gem 'ckeditor', :git => 'git://github.com/galetahub/ckeditor.git'


gem 'mongoid-paperclip', :require => 'mongoid_paperclip'

gem "less-rails"
gem 'twitter-bootstrap-rails',:git => 'git://github.com/diowa/twitter-bootstrap-rails.git',:branch=>'bootstrap-3.0.0'
gem 'csso-rails' # CSS Optimizer
gem 'therubyracer', platforms: :ruby
gem 'sprockets'
gem 'sprockets-image_compressor'
gem 'haml-rails'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-fileupload-rails'
gem "jquery-turbolinks"
gem "turbolinks"
gem "jbuilder", "~> 1.2"



gem 'dalli'
gem 'kgio'
gem 'identity_cache'
gem 'rack-cache'
gem 'multi_fetch_fragments', github: 'robotmay/multi_fetch_fragments'


gem_group :test do
  gem "mongoid-rspec"
  gem "ffaker"
  gem "simplecov", require: false
  gem "database_cleaner"
  gem "rb-inotify", "~> 0.9"
  gem "rspec-rails"
  gem "capybara"
  gem "factory_girl_rails"
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'cucumber-rails'
  gem 'launchy'
  gem 'konacha'
  gem 'timecop'
  gem 'zeus'
end

gem_group :development do
  gem "guard-rspec"
  gem "pry"
  gem "quiet_assets"
  gem "html2haml"
  gem 'guard-bundler'
  gem 'guard-cucumber'
  gem 'guard-rails'
  gem 'factory_girl_rails'
  gem 'quiet_assets'
  gem 'figaro'
  gem 'better_errors'
  gem 'hub'
  gem 'meta_request'
end

gem 'sidekiq'
gem 'airbrake'
gem 'newrelic_rpm'
gem 'coveralls', require: false


run 'bundle install'

### Generators
generate 'mongoid:config'
generate 'bootstrap:install less'
generate 'simple_form:install --bootstrap'
generate 'devise:install'
generate 'devise:views'
generate 'cancan:ability'
generate 'ckeditor:install --orm=mongoid --backend=paperclip'
generate 'rspec:install'
generate 'cucumber:install'
generate 'kaminari:config'
generate 'kaminari:views --bootstrap'

run "for file in app/views/devise/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done"

application do  <<eos
  config.generators do |g|
    g.orm             :mongoid
    g.template_engine :haml
    g.test_framework  :rspec
    g.stylesheets     false
  end
eos
end

generate :controller, "home index"

generate "rolify Role User --orm=mongoid"
##Routes
route 'resources :users'
route <<-eos

  devise_for :users, controllers: {
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
eos
route <<-eos

  authenticated :user do
    root to: 'home#index', as: :authenticated_root
  end

  unauthenticated do
    root to: "home#index"
  end
eos


### Simple form
inject_into_file 'config/initializers/simple_form_bootstrap.rb', after: 'SimpleForm.setup do |config|' do
  <<-eos

  config.wrappers :inline_checkbox, :tag => 'div', :class => 'control-group', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :label_input, :class => 'checkbox inline'
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end
  eos
end

### Bootstrap JS
inject_into_file "app/assets/javascripts/application.js", "//= require bootstrap\n", before: '//= require_tree'

### Devise OmniAuth providers config
inject_into_file 'config/initializers/devise.rb', after: /# config.omniauth .*?\n/ do
  <<-eos
  config.omniauth :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope: 'email,user_birthday,read_stream'
  config.omniauth :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  eos
end

remove_file 'app/assets/stylesheets/application.css'

### Download misc files
source_url = 'https://github.com/krushi123/gurujada-startup-app'
get "#{source_url}/app/controllers/users/omniauth_callbacks_controller.rb",   'app/controllers/users/omniauth_callbacks_controller.rb'
get "#{source_url}/app/controllers/users/passwords_controller.rb",            'app/controllers/users/passwords_controller.rb'
get "#{source_url}/app/controllers/users/registrations_controller.rb",        'app/controllers/users/registrations_controller.rb'
get "#{source_url}/app/helpers/users_helper.rb",                              'app/helpers/users_helper.rb'
get "#{source_url}/app/models/user.rb",                                       'app/models/user.rb'
get "#{source_url}/app/models/role.rb",                                       'app/models/role.rb'
get "#{source_url}/app/models/identity.rb",                                   'app/models/identity.rb'
get "#{source_url}/app/models/user/auth_definitions.rb",                      'app/models/user/auth_definitions.rb'
get "#{source_url}/config/config.yml",                                        'config/config.yml'
get "#{source_url}/config/initializers/rolify.rb",                            'config/initializers/rolify.rb'
get "#{source_url}/app/controllers/application_controller.rb",                'app/controllers/application_controller.rb'
get "#{source_url}/app/views/layouts/_messages.html.haml",                     'app/views/layouts/_messages.html.haml'
get "#{source_url}/app/views/layouts/_navigation.html.haml",                   'app/views/layouts/_navigation.html.haml'
get "#{source_url}/app/views/layouts/application.html.haml",                   'app/views/layouts/application.html.haml'
get "#{source_url}/db/seeds.rb",                                              'db/seeds.rb'
get "#{source_url}/app/assets/stylesheets/bootstrap_and_overrides.css.less",  'app/assets/stylesheets/bootstrap_and_overrides.css.less'
get "#{source_url}/app/assets/stylesheets/application.css.less",  'app/assets/stylesheets/application.css.less'
get "#{source_url}/app/assets/stylesheets/bootswatch.less",  'app/assets/stylesheets/bootswatch.less'
get "#{source_url}/app/assets/stylesheets/variables.less",  'app/assets/stylesheets/variables.less'

remove_file 'app/views/layouts/application.html.erb'


git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

if yes?("Initialize GitHub repository?")
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say "Repository already exists:"
    say "#{git_uri}"
  else
    username = ask "What is your GitHub username?"
    run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
    git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
    git push: %Q{ origin master }
  end
end
