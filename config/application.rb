require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module FoodStella
  class Application < Rails::Application
    # config.assets.enabled = false

    # the new line added for autoload of lib
    # config.autoload_paths += %W(#{config.root}/lib)
    Rails.application.config.action_cable.disable_request_forgery_protection = true
    config.action_cable.mount_path = '/cable'
    config.action_cable.allowed_request_origins = ['https://foodstella.herokuapp.com', 'http://foodstella.herokuapp.com', 'http://foodstella.com', 'https://foodstella.com', 'foodstella.com']
    #config.action_cable.allowed_request_origins = ['http://www.foodstella.com ']

    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
