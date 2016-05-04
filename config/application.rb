require File.expand_path('../boot', __FILE__)

require 'rails'
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HmRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
    config.i18n.available_locales = %w(en de)

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.action_view.embed_authenticity_token_in_remote_forms = true
  end
end

if ENV["HANGMAN_WORD_LIST"]
  error_msg = "Invalid word list location #{ENV["HANGMAN_WORD_LIST"]}"
else
  ENV["HANGMAN_WORD_LIST"] = "/usr/share/dict/words"

  error_msg = "Please supply the word list location with the ENV variable 'HANGMAN_WORD_LIST'"
end

raise error_msg unless File.exist?(ENV["HANGMAN_WORD_LIST"]) and File.readable?(ENV["HANGMAN_WORD_LIST"])

