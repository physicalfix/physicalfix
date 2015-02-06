# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
if Gem::VERSION >= "1.3.6" 
  module Rails
    class GemDependency
      def requirement
        r = super
        (r == Gem::Requirement.default) ? nil : r
      end
    end
  end
end
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug'

  # If you include more than the below, you get:
  # A copy of NewRelic::Agent::Agent has been removed from the module tree but is still active! (ArgumentError)
  # config.gem 'rspec', :version => '1.3.1'
  config.gem 'haml', :version => '3.0.9'
  config.gem 'chronic', :version => '0.2.3'
  config.gem 'whenever', :version => '0.4.2'
  config.gem 'httparty', :version => '0.5.2'
  config.gem 'raspell', :version => '1.1'
  config.gem 'chargify_api_ares', :version => '0.3.4'
  config.gem 'will_paginate', :version => '2.3.14'
  config.gem 'sunspot_rails', :version => '1.1.0', :lib => 'sunspot/rails'

  config.gem 'saikuro', :version => '1.1.0'
  config.gem 'sexp_processor', :version => '4.4.5'
  config.gem 'rake', :version => '0.8.3'
  config.gem 'rcov', :version => '1.0.0'
  config.gem 'right_aws', :version => '2.0.0'
  config.gem 'mysql', :version => '2.9.1'
  config.gem 'flog', :version => '2.2.0'
  config.gem 'flay', :version => '2.6.1'
  config.gem 'i18n', :version => '0.6.11'
  config.gem 'chronic', :version => '0.6.2'
  config.gem 'churn', :version => '0.0.15'
  config.gem 'crack', :version => '0.1.6'

  config.gem 'metric_fu', :version => '1.3.0'
  config.gem 'mongo_mapper' # updated this from 0.7.6 to 0.8.6 for use with new mongo db
  config.gem 'rake', :version => '0.8.3'

  # config.gem 'aws-s3', :version => "0.6.2" # don't include aws-s3 it crashes startup. probably loaded elsewhere
  # config.gem 'god', :version => '0.10.1'
  # config.gem 'right_aws', :version => '2.0.0'
  # config.gem 'sinatra', :version => '1.0'
  # config.gem 'thin', :version => '1.2.7'
  # config.gem 'mysql'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_physicalfix_session',
    :secret      => 'fa63e6497bc96c95bd51751510b1b4b8112a317f75ab54970a995787c4eccf8bd88552f8ce1d74ffde67b6a47613c0de28c3eac0fdf774224e33aa3547b1e614'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  config.action_mailer.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true,
    :user_name => "support@physicalfix.com",
    :password => "Phy51c4lF1x"
  }
  config.cache_store = :mem_cache_store
  config.time_zone = 'UTC'
end

class ActiveRecord::Base
  include ActionController::UrlWriter
end

chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'chargify.yml'))

ENV['RAILS_ENV'] ||= 'development'

Chargify.configure do |c|
  c.subdomain = chargify_config[ENV['RAILS_ENV']]['subdomain']
  c.api_key   = chargify_config[ENV['RAILS_ENV']]['api_key']
end
